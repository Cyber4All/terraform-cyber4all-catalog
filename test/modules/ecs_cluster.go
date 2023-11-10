package modules

import (
	"fmt"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/service/ecs"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func DeployEcsClusterUsingTerraform(t *testing.T, workingDir string) {
	// Generate a unique ID
	uniqueId := random.UniqueId()
	// Get a random AWS region
	awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "us-east-2"}, nil)
	test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)
	// Get a ECS AMI
	amiId := aws.GetEcsOptimizedAmazonLinuxAmi(t, awsRegion)
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

func ValidateEcsCluster(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	// Get the random id
	randomId := terraform.Output(t, terraformOptions, "random_id")

	expectedClusterName := terraform.Output(t, terraformOptions, "cluster_name")

	// Check that the cluster exists
	cluster := assertClusterExists(t, awsRegion, expectedClusterName)

	// Check the status of the cluster
	assertClusterStatusIsActive(t, cluster, expectedClusterName, awsRegion)

	// Check the capacity providers
	assertCapacityProvidersExist(t, cluster)

	// Check the default capacity provider strategy
	assertDefaultCapacityProviderStrategyIsClusterName(t, cluster, randomId)

	// Check Registered Container Instances
	assertRegsiteredContainerInstancesIsGreaterThanZero(t, cluster, awsRegion, expectedClusterName)
}

func assertClusterExists(t *testing.T, awsRegion string, expectedClusterName string) *ecs.Cluster {
	// Get the cluster
	cluster := aws.GetEcsCluster(t, awsRegion, expectedClusterName)
	// Assert that it exists
	assert.NotNil(t, cluster, "Cluster recieved from AWS with name: %s is nil", expectedClusterName)
	// Print the cluster
	t.Logf("The cluster is: %s", cluster.String())

	return cluster
}

func assertClusterStatusIsActive(t *testing.T, cluster *ecs.Cluster, expectedClusterName string, awsRegion string) {
	status := cluster.Status
	t.Logf("The cluster status is: %s", *status)
	startTime := time.Now()
	timeout := 5 * time.Minute
	// Wait for the cluster status to no longer be PROVISIONING
	for *status == "PROVISIONING" && time.Since(startTime) < timeout {
		cluster = aws.GetEcsCluster(t, awsRegion, expectedClusterName)
		status = cluster.Status
		// Sleep for 5 seconds
		t.Logf("Waiting for cluster to be ACTIVE, currently: %s", *status)
		time.Sleep(5 * time.Second)
	}
	// Assert that the cluster is active
	assert.Equal(t, "ACTIVE", *status, "Cluster status is not ACTIVE, currently: %s", *status)
}

func assertCapacityProvidersExist(t *testing.T, cluster *ecs.Cluster) {
	capacityProviders := cluster.CapacityProviders
	containsFargate := false
	for _, cp := range capacityProviders {
		t.Logf("Capacity provider: %s", *cp)
		if *cp == "FARGATE" {
			containsFargate = true
		}
	}
	assert.True(t, containsFargate, "Capacity providers does not contain FARGATE")
}

func assertDefaultCapacityProviderStrategyIsClusterName(t *testing.T, cluster *ecs.Cluster, randomId string) {
	defaultCapacityProviderStrategy := cluster.DefaultCapacityProviderStrategy
	expectedDcps := fmt.Sprintf("cluster-test%s-cp", randomId)
	assert.Equal(t, 1, len(defaultCapacityProviderStrategy), "Default capacity provider strategy does not have length 1")
	assert.Equal(t, expectedDcps, *defaultCapacityProviderStrategy[0].CapacityProvider, "Default capacity provider strategy does not have the expected capacity provider")
}

func assertRegsiteredContainerInstancesIsGreaterThanZero(t *testing.T, cluster *ecs.Cluster, awsRegion string, expectedClusterName string) {
	// Every 30 seconds, check the number of registered container instances, fail after 10 minutes
	// If its not greater than 0, fail the test
	startTime := time.Now()
	timeout := 10 * time.Minute

	// Get the number of registered container instances
	registeredContainerInstances := cluster.RegisteredContainerInstancesCount
	for *registeredContainerInstances < 1 {
		t.Logf("The number of registered container instances is: %d. Sleeping for 30 seconds...", *registeredContainerInstances)
		time.Sleep(30 * time.Second)
		cluster = aws.GetEcsCluster(t, awsRegion, expectedClusterName)
		registeredContainerInstances = cluster.RegisteredContainerInstancesCount
		t.Logf("Current registered container instances: %d", *registeredContainerInstances)

		if time.Since(startTime) > timeout {
			t.Fatalf("Timed out waiting for registered container instances to be greater than 0")
		}
	}

	assert.True(t, *registeredContainerInstances > 0, "Number of registered container instances is not greater than 0, currently: %d", *registeredContainerInstances)
}
