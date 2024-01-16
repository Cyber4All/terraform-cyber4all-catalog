package modules

import (
	"bytes"
	"context"
	"crypto/tls"
	"fmt"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/cloudwatch"
	cloudwatchtypes "github.com/aws/aws-sdk-go-v2/service/cloudwatch/types"
	"github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
	"github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2/types"
	"github.com/aws/aws-sdk-go/service/ecs"
	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func DeployEcsServiceUsingTerraform(t *testing.T, workingDir string) {
	// Generate unique ID
	uniqueId := strings.ToLower(random.UniqueId())

	// Get a random AWS region
	awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "us-east-2"}, nil)
	test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)

	// Get a ECS AMI with the latest ECS agent
	filters := map[string][]string{
		"name":                {"al2023-ami-ecs-hvm*"},
		"virtualization-type": {"hvm"},
		"architecture":        {"x86_64"},
		"root-device-type":    {"ebs"},
	}
	amiId := aws.GetMostRecentAmiId(t, awsRegion, "amazon", filters)

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"random_id":                uniqueId,
			"region":                   awsRegion,
			"cluster_instance_ami":     amiId,
			"external_container_image": "cyber4all/mock-container-image:latest",
		},
	})

	// Save the options so later test stages can use them
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
}

// ValidateEcsService validates the ECS service module with the
// following assertions:
// - The ECS service is in a stable state
// - The ECS service is receiving traffic from the load balancer
// - The ECS service can retrieve a secret from secrets manager
// - The ECS service can reach the internal service via ServiceConnect
// - The ECS service can be deployed using the deploy-ecs-service.py script
// - The ECS service can be scaled out
func ValidateEcsService(t *testing.T, workingDir string) {
	wg := &sync.WaitGroup{}

	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	regionName := test_structure.LoadString(t, workingDir, "awsRegion")

	// Get outputs for assertions
	ecsClusterName := terraform.Output(t, terraformOptions, "ecs_cluster_name")
	externalServiceName := terraform.Output(t, terraformOptions, "external_service_name")
	// externalServiceAutoScalingAlarmArns := terraform.OutputList(t, terraformOptions, "external_service_auto_scaling_alarm_arns")
	externalTargetGroupArn := terraform.Output(t, terraformOptions, "external_service_target_group_arn")
	internalEcsTaskContainerPort := terraform.Output(t, terraformOptions, "internal_ecs_task_container_port")
	internalServiceName := terraform.Output(t, terraformOptions, "internal_service_name")
	loadbalancerDnsName := terraform.Output(t, terraformOptions, "alb_dns_name")
	loadbalancerName := terraform.Output(t, terraformOptions, "alb_name")

	// Check that the services exist and
	// are in a stable state...
	wg.Add(2)
	go assertEcsServiceIsStable(t, wg, regionName, ecsClusterName, internalServiceName)
	go assertEcsServiceIsStable(t, wg, regionName, ecsClusterName, externalServiceName)
	wg.Wait()

	// The following assertions can be run in parallel
	// with the above assertions
	wg.Add(3)

	// Check that the load balancer attached service
	// recieves traffic
	go assertEcsServiceReceivesTraffic(t, wg, regionName, loadbalancerName, externalTargetGroupArn)

	// Check that the a service can retrieve a secret
	// from secrets manager
	go assertEcsServiceCanRetrieveSecret(t, wg, loadbalancerDnsName)

	// Check that the internal service can be reached
	// from the external service via ServiceConnect
	internalServicePort, err := strconv.Atoi(internalEcsTaskContainerPort)
	if err != nil {
		t.Fatal(err)
	}
	go assertEcsServiceCanReachInternalService(t, wg, loadbalancerDnsName, internalServiceName, internalServicePort)

	// Wait for all the above assertions to complete
	wg.Wait()

	// Check that deployments updating the container image
	// externally do not override the image specified in the
	// assertEcsServiceExternalDeployment(t, terraformOptions, regionName, ecsClusterName, externalServiceName)

	// Check that the service can be scaled out
	// assertEcsServiceAutoScaling(t, regionName, ecsClusterName, externalServiceName, externalServiceAutoScalingAlarmArns)
}

// assertEcsServiceIsStable asserts that the ECS service is in a stable state
// (i.e. not updating or draining) and that the service exists. This function
// supports running in parallel with other tests.
func assertEcsServiceIsStable(t *testing.T, wg *sync.WaitGroup, awsRegion string, clusterName string, serviceName string) {
	defer wg.Done()

	message := retry.DoWithRetry(
		t,
		fmt.Sprintf("%s stability:", serviceName),
		28,                            // maxRetries
		time.Duration(15*time.Second), // sleepBetweenRetries
		func() (string, error) {
			// Get the service
			service := aws.GetEcsService(t, awsRegion, clusterName, serviceName)

			// Check that the service exists
			assert.NotNil(t, service, "Service %s does not exist", serviceName)

			// The service is considered stable if it has a single deployment
			// and that deployment is in the completed state and the service
			// has reached its desired count.
			if len(service.Deployments) == 1 {
				deployment := service.Deployments[0]

				if *deployment.RolloutState == ecs.DeploymentRolloutStateCompleted &&
					*service.DesiredCount == *service.RunningCount {
					return fmt.Sprintf("Service %s is stable", serviceName), nil

				} else if *deployment.RolloutState == ecs.DeploymentRolloutStateFailed {
					return "", retry.FatalError{Underlying: fmt.Errorf(*deployment.RolloutStateReason, serviceName)}
				}
			}

			return "", fmt.Errorf("service %s is not stable yet", serviceName)
		},
	)

	t.Log(message)
}

// assertEcsServiceReceivesTraffic asserts that the ECS service is receiving traffic
// from the load balancer. This function supports running in parallel with other tests.
func assertEcsServiceReceivesTraffic(t *testing.T, wg *sync.WaitGroup, awsRegion string, loadBalancerName string, targetGroupArn string) {
	defer wg.Done()

	// Connect to aws using aws sdk
	cfg, err := config.LoadDefaultConfig(context.TODO())
	assert.NoError(t, err)

	client := elasticloadbalancingv2.NewFromConfig(cfg, func(o *elasticloadbalancingv2.Options) {
		o.Region = awsRegion
	})

	// Get the target health
	resp, err := client.DescribeTargetHealth(context.TODO(), &elasticloadbalancingv2.DescribeTargetHealthInput{
		TargetGroupArn: &targetGroupArn,
	})
	assert.NoError(t, err)

	// Check that there is at least one target
	assert.NotEmpty(t, resp.TargetHealthDescriptions, "Expected at least one target for %s", loadBalancerName)

	// Check that each target is healthy. We assume
	// since the service is stable that the target
	// is healthy hence retries are not necessary
	for _, target := range resp.TargetHealthDescriptions {
		assert.Equal(t,
			types.TargetHealthStateEnumHealthy, // expected
			target.TargetHealth.State,          // actual
			"Target is not in healthy state: (%s) %s - %s", target.TargetHealth.State, target.TargetHealth.Reason, target.TargetHealth.Description,
		)
	}

	// Get loadbalancer DNS name
	loadBalancers, err := client.DescribeLoadBalancers(context.TODO(), &elasticloadbalancingv2.DescribeLoadBalancersInput{
		Names: []string{loadBalancerName},
	})
	assert.NoError(t, err)

	// Check that there is one load balancer
	assert.Equal(t, 1, len(loadBalancers.LoadBalancers), "Expected one load balancer for %s, recieved ", loadBalancerName, len(loadBalancers.LoadBalancers))

	// Check that the load balancer has a DNS name
	assert.NotEmpty(t, loadBalancers.LoadBalancers[0].DNSName, "Expected load balancer %s to have a DNS name", loadBalancerName)

	// Check that the load balancer DNS name resolves
	// to the load balancer target
	http_helper.HttpGetWithRetryWithCustomValidation(t,
		fmt.Sprintf("http://%s", *loadBalancers.LoadBalancers[0].DNSName),
		&tls.Config{},
		5,             // retries
		5*time.Second, // sleepBetweenRetries
		func(statusCode int, body string) bool {
			// Check that the body.message is "Mock Container Image API"
			return statusCode == 200 && strings.Contains(body, "Mock Container Image API")
		},
	)
}

// assertEcsServiceCanRetrieveSecret asserts that the ECS service can retrieve
// a secret from secrets manager. This function supports running in parallel with
// other tests.
//
// This function assumes the following:
//
//  1. mock-container-image docker image is being used in task definition
//     a. API has the /test/env endpoint which returns the value of the
//     environment variable SECRET.
//  2. The ECS service module set the SECRET environment variable using
//     the secrets manager secret.
func assertEcsServiceCanRetrieveSecret(t *testing.T, wg *sync.WaitGroup, dnsName string) {
	defer wg.Done()

	http_helper.HttpGetWithRetryWithCustomValidation(t,
		fmt.Sprintf("http://%s/test/env", dnsName),
		&tls.Config{},
		5,             // retries
		5*time.Second, // sleepBetweenRetries
		func(statusCode int, body string) bool {
			// Check that the body.message is "SUPER_SECRET_VALUE"
			return statusCode == 200 && strings.Contains(body, "Secret: SUPER_SECRET_VALUE")
		},
	)
}

// assertEcsServiceCanReachInternalService asserts that the ECS service can
// reach the internal service via ServiceConnect. This function supports running
// in parallel with other tests.
//
// This function assumes the following:
//
//  1. mock-container-image docker image is being used in task definition
//     a. API has the POST /proxy endpoint which proxies the request to
//     the internal service.
func assertEcsServiceCanReachInternalService(t *testing.T, wg *sync.WaitGroup, dnsName string, internalServiceName string, internalServicePort int) {
	defer wg.Done()

	expectedBody := "Hello from the external service!"
	body := bytes.NewBuffer([]byte(fmt.Sprintf(`{"proxyUrl": "http://%s:%d/test?proxyPhrase=%s"}`, internalServiceName, internalServicePort, expectedBody)))

	http_helper.HTTPDoWithCustomValidation(t,
		"POST",                                  // method
		fmt.Sprintf("http://%s/proxy", dnsName), // url
		body,                                    // body
		map[string]string{"Content-Type": "application/json"}, // headers
		func(statusCode int, response string) bool { // validator
			return statusCode == 200 && strings.Contains(response, expectedBody)
		},
		nil,
	)
}

// assertEcsServiceDeploymentScript asserts that the ECS service can be deployed
// externally without being overriden with the container image specified in the
// terraform configuration
func assertEcsServiceExternalDeployment(t *testing.T, terraformOptions *terraform.Options, regionName string, clusterName string, serviceName string) {
	expectedContainerImage := "cyber4all/mock-container-image:1.0.0"

	// Deploy the service externally
	deployEcsService(t, regionName, clusterName, serviceName, expectedContainerImage)

	// Check that the service will use the externally deployed
	// image on new terraform apply (rather than overriding)

	// Remove the external_container_image variable
	// from the terraform options. This will cause the
	// service to use the image specified in the latest
	// deployment of the service.
	terraformOptions.Vars["external_container_image"] = ""

	// Apply the terraform changes
	terraform.Apply(t, terraformOptions)

	// Wait for the service to reach a stable state
	inner_wg := &sync.WaitGroup{}
	inner_wg.Add(1)
	go assertEcsServiceIsStable(t, inner_wg, regionName, clusterName, serviceName)
	inner_wg.Wait()

	// Check that the outputs reflect the expected container image
	outputContainerImage := terraform.Output(t, terraformOptions, "external_ecs_task_essential_image")
	assert.Equal(t, expectedContainerImage, outputContainerImage, "Expected service to use container image %s, recieved %s", expectedContainerImage, outputContainerImage)

	// Check that the latest deployment is using the expected container image
	taskDefinition := aws.GetEcsService(t, regionName, clusterName, serviceName).Deployments[0].TaskDefinition
	actualContainerImage := aws.GetEcsTaskDefinition(t, regionName, *taskDefinition).ContainerDefinitions[0].Image
	assert.Equal(t, expectedContainerImage, *actualContainerImage, "Expected service to use container image %s, recieved %s", expectedContainerImage, *actualContainerImage)
}

// deployEcsService deploys the ECS service using the specified container image.
func deployEcsService(t *testing.T, regionName string, clusterName string, serviceName string, containerImage string) *string {
	// Get the task definition arn
	taskDefinitionArn := aws.GetEcsService(t, regionName, clusterName, serviceName).Deployments[0].TaskDefinition

	client := aws.NewEcsClient(t, regionName)

	// Get the task definition, can't use GetEcsTaskDefinition from terratest
	// because it doesn't support the latest version of the ecs sdk which includes
	// service connect compatibility
	taskDefinitionOutput, err := client.DescribeTaskDefinition(&ecs.DescribeTaskDefinitionInput{
		TaskDefinition: taskDefinitionArn,
	})
	if err != nil {
		t.Fatal(err)
	}
	taskDefinition := taskDefinitionOutput.TaskDefinition

	// Update the container image
	taskDefinition.ContainerDefinitions[0].Image = &containerImage

	// Register the new task definition
	registerTaskDefinitionOutput, err := client.RegisterTaskDefinition(&ecs.RegisterTaskDefinitionInput{
		ContainerDefinitions:    taskDefinition.ContainerDefinitions,
		Cpu:                     taskDefinition.Cpu,
		EphemeralStorage:        taskDefinition.EphemeralStorage,
		ExecutionRoleArn:        taskDefinition.ExecutionRoleArn,
		Family:                  taskDefinition.Family,
		InferenceAccelerators:   taskDefinition.InferenceAccelerators,
		IpcMode:                 taskDefinition.IpcMode,
		Memory:                  taskDefinition.Memory,
		NetworkMode:             taskDefinition.NetworkMode,
		PidMode:                 taskDefinition.PidMode,
		PlacementConstraints:    taskDefinition.PlacementConstraints,
		ProxyConfiguration:      taskDefinition.ProxyConfiguration,
		RequiresCompatibilities: taskDefinition.RequiresCompatibilities,
		RuntimePlatform:         taskDefinition.RuntimePlatform,
		TaskRoleArn:             taskDefinition.TaskRoleArn,
		Volumes:                 taskDefinition.Volumes,
	})
	if err != nil {
		t.Fatal(err)
	}

	// Update the service to use the new task definition
	_, err = client.UpdateService(&ecs.UpdateServiceInput{
		Cluster:        &clusterName,
		Service:        &serviceName,
		TaskDefinition: registerTaskDefinitionOutput.TaskDefinition.TaskDefinitionArn,
	})
	if err != nil {
		t.Fatal(err)
	}

	// Wait for the service to reach a stable state
	inner_wg := &sync.WaitGroup{}
	inner_wg.Add(1)
	go assertEcsServiceIsStable(t, inner_wg, regionName, clusterName, serviceName)
	inner_wg.Wait()

	return registerTaskDefinitionOutput.TaskDefinition.TaskDefinitionArn
}

// assertEcsServiceAutoScaling asserts that the ECS service can be scaled out
// and in. This function assumes the following:
// 1. The ECS service is using TargetTrackingScaling
// 2. The ECS service has a scale out alarm
// 3. The ECS service has a 50 threshold for 3 datapoints over a 180 period
func assertEcsServiceAutoScaling(t *testing.T, regionName string, clusterName string, serviceName string, alarmNames []string) {
	// Parse the alarm ARNs into alarm names
	var scaleOutAlarmName string
	for _, alarmArn := range alarmNames {
		splitAlarmArn := strings.Split(alarmArn, ":")
		alarmName := splitAlarmArn[len(splitAlarmArn)-1]

		if strings.Contains(alarmName, "AlarmHigh") {
			scaleOutAlarmName = alarmName
		}
	}

	// Check that the scale out alarm name is set
	assert.NotNil(t, scaleOutAlarmName, "Expected scale out alarm name to be set")

	// Connect to aws using aws sdk
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		t.Fatal(err)
	}
	cloudwatchClient := cloudwatch.NewFromConfig(cfg, func(o *cloudwatch.Options) {
		o.Region = regionName
	})

	// Get the current desired count
	currentDesiredCount := aws.GetEcsService(t, regionName, clusterName, serviceName).DesiredCount
	t.Logf("Current desired count: %d", *currentDesiredCount)

	// Test Scale Out
	stateReasonData := `{
		"version": "1.0",
		"statistic": "Average",
        "period": 60,
        "recentDatapoints": [
            100,
			100,
			100
        ],
        "threshold": 50
	}`
	var maxRecords int32 = 1
	stateReason := "Setting alarm to ALARM state for testing"

	// Set the scale out alarm to ALARM state
	cloudwatchClient.SetAlarmState(context.TODO(), &cloudwatch.SetAlarmStateInput{
		AlarmName:       &scaleOutAlarmName,
		StateValue:      cloudwatchtypes.StateValueAlarm,
		StateReason:     &stateReason,
		StateReasonData: &stateReasonData,
	})

	t.Log("Waiting 15 seconds for scale out alarm to trigger...")
	time.Sleep(15 * time.Second)

	// Get the latest alarm history
	alarmHistory, err := cloudwatchClient.DescribeAlarmHistory(context.TODO(), &cloudwatch.DescribeAlarmHistoryInput{
		AlarmName:  &scaleOutAlarmName,
		MaxRecords: &maxRecords,
	})
	if err != nil {
		t.Fatal(err)
	}

	// Check that there is one alarm history item
	assert.Equal(t, 1, len(alarmHistory.AlarmHistoryItems), "Expected one alarm history item, recieved %d", len(alarmHistory.AlarmHistoryItems))

	// Check that the latest alarm history is Successfully executed action
	assert.Contains(t, *alarmHistory.AlarmHistoryItems[0].HistorySummary, "Successfully executed action", "Expected alarm history to be Successfully executed action, recieved %s", *alarmHistory.AlarmHistoryItems[0].HistorySummary)

	// Get the updated desired count
	updatedDesiredCount := aws.GetEcsService(t, regionName, clusterName, serviceName).DesiredCount

	// Check that the updated desired count is greater than the current desired count
	assert.Greater(t, *updatedDesiredCount, *currentDesiredCount, "Expected desired count to be greater than %d, recieved %d", *currentDesiredCount, *updatedDesiredCount)
}
