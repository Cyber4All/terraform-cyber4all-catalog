package modules

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func DeployEcsClusterUsingTerraform(t *testing.T, workingDir string, awsRegion string) {
	// Generate a unique ID
	uniqueId := random.UniqueId()
	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"random_id": uniqueId,
			"region":    awsRegion,
		},
	})

	// Save the options so later test stages can use them
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// Deploy the cluster
	terraform.InitAndApply(t, terraformOptions)
}

func ValidateEcsCluster(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	// terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	// awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")
}
