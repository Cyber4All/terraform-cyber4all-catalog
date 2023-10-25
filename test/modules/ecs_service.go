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
	"github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
	"github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2/types"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
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
			"random_id":            uniqueId,
			"region":               awsRegion,
			"cluster_instance_ami": amiId,
		},
	})

	// Save the options so later test stages can use them
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
}

func ValidateEcsService(t *testing.T, workingDir string) {
	var wg sync.WaitGroup

	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	clusterName := terraform.Output(t, terraformOptions, "ecs_cluster_name")
	internalServiceName := terraform.Output(t, terraformOptions, "internal_service_name")
	externalServiceName := terraform.Output(t, terraformOptions, "external_service_name")

	// Check that the services exist and
	// are in a stable state...
	wg.Add(2)
	go assertEcsServiceIsStable(t, awsRegion, clusterName, internalServiceName, &wg)
	go assertEcsServiceIsStable(t, awsRegion, clusterName, externalServiceName, &wg)
	wg.Wait()

	// Check that the services are producing logs
	assertEcsServiceSendsLogs(t, awsRegion, fmt.Sprintf("/ecs/service/%s", internalServiceName))
	assertEcsServiceSendsLogs(t, awsRegion, fmt.Sprintf("/ecs/service/%s", externalServiceName))

	// Check that the load balancer attached service
	// recieves traffic
	targetGroupArn := terraform.Output(t, terraformOptions, "external_service_target_group_arn")
	loadbalancerName := terraform.Output(t, terraformOptions, "alb_name")
	assertEcsServiceReceivesTraffic(t, awsRegion, loadbalancerName, targetGroupArn)

	// Check that the a service can retrieve a secret
	// from secrets manager
	dnsName := terraform.Output(t, terraformOptions, "alb_dns_name")
	assertEcsServiceCanRetrieveSecret(t, dnsName)

	// Check that the internal service can be reached
	// from the external service via ServiceConnect
	internalServicePort, err := strconv.Atoi(terraform.Output(t, terraformOptions, "internal_ecs_task_container_port"))
	if err != nil {
		t.Fatal(err)
	}
	assertEcsServiceCanReachInternalService(t, dnsName, internalServiceName, internalServicePort)

	// Check that deployments using the script are successful

	// Check that the service will use the externally deployed
	// image on new terraform apply (rather than overriding)

	// Check that the service can be scaled out and in

	// Check that a failed deployment will roll back to the
	// previous deployment

}

// assertEcsServiceIsStable asserts that the ECS service is in a stable state
// (i.e. not updating or draining) and that the service exists. This function
// supports running in parallel with other tests.
func assertEcsServiceIsStable(t *testing.T, awsRegion string, clusterName string, serviceName string, wg *sync.WaitGroup) {
	defer wg.Done()

	message := retry.DoWithRetry(
		t,
		fmt.Sprintf("%s stability:", serviceName),
		40,                            // maxRetries
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
					return "", retry.FatalError{Underlying: fmt.Errorf(*deployment.RolloutStateReason)}
				}
			}

			return "", fmt.Errorf("service %s is not stable yet", serviceName)
		},
	)

	fmt.Println(message)
}

// assertEcsServiceSendsLogs asserts that the ECS service is sending logs to the
// specified log group.
func assertEcsServiceSendsLogs(t *testing.T, awsRegion string, logGroup string) {
	client := aws.NewCloudWatchLogsClient(t, awsRegion)

	// Describe the log streams
	streams, err := client.DescribeLogStreams(&cloudwatchlogs.DescribeLogStreamsInput{
		LogGroupName: &logGroup,
	})

	// Check that there were no errors
	if err != nil {
		t.Fatal(err)
	}

	// Check that there is at least one log stream
	assert.NotEmpty(t, streams.LogStreams, "Expected at least one log stream for %s", logGroup)

	// Get the logs
	output, err := client.GetLogEvents(&cloudwatchlogs.GetLogEventsInput{
		LogGroupName:  &logGroup,
		LogStreamName: streams.LogStreams[0].LogStreamName,
	})

	// Check that there were no errors
	if err != nil {
		t.Fatal(err)
	}

	// Convert the log events to a slice of strings
	entries := []string{}
	for _, event := range output.Events {
		entries = append(entries, *event.Message)
	}

	// Check that the service is sending logs
	assert.NotEmpty(t, entries, "Expected service to send logs to %s", logGroup)
}

// assertEcsServiceReceivesTraffic asserts that the ECS service is receiving traffic
// from the load balancer.
func assertEcsServiceReceivesTraffic(t *testing.T, awsRegion string, loadBalancerName string, targetGroupArn string) {
	// Connect to aws using aws sdk
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		t.Fatal(err)
	}

	client := elasticloadbalancingv2.NewFromConfig(cfg, func(o *elasticloadbalancingv2.Options) {
		o.Region = awsRegion
	})

	resp, err := client.DescribeTargetHealth(context.TODO(), &elasticloadbalancingv2.DescribeTargetHealthInput{
		TargetGroupArn: &targetGroupArn,
	})
	if err != nil {
		t.Fatal(err)
	}

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
	if err != nil {
		t.Fatal(err)
	}

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
// a secret from secrets manager.
//
// This function assumes the following:
//
//  1. mock-container-image docker image is being used in task definition
//     a. API has the /test/env endpoint which returns the value of the
//     environment variable SECRET.
//  2. The ECS service module set the SECRET environment variable using
//     the secrets manager secret.
func assertEcsServiceCanRetrieveSecret(t *testing.T, dnsName string) {
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
// reach the internal service via ServiceConnect.
//
// This function assumes the following:
//
//  1. mock-container-image docker image is being used in task definition
//     a. API has the POST /proxy endpoint which proxies the request to
//     the internal service.
func assertEcsServiceCanReachInternalService(t *testing.T, dnsName string, internalServiceName string, internalServicePort int) {
	url := fmt.Sprintf("http://%s/proxy", dnsName)
	expectedBody := "Hello from the external service!"
	body := bytes.NewBuffer([]byte(fmt.Sprintf(`{"proxyUrl": "http://%s:%d/test?proxyPhrase=%s"}`, internalServiceName, internalServicePort, expectedBody)))
	headers := map[string]string{"Content-Type": "application/json"}

	customValidation := func(statusCode int, response string) bool {
		return statusCode == 200 && strings.Contains(response, expectedBody)
	}

	http_helper.HTTPDoWithCustomValidation(t, "POST", url, body, headers, customValidation, nil)
}
