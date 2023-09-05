package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// This test suite deploys the secrets-manager module from examples/secrets-manager.
// The test is broken into "stages" so you can skip stages by setting environment variables (e.g.,
// skip stage "apply" by setting the environment variable "SKIP_apply=true"), which speeds up iteration when
// running this test over and over again locally.
func TestSecretsManagerExample(t *testing.T) {
	t.Parallel()

	// The folder where we have our Terraform code
	workingDir := "../examples/secrets-manager"

	// At the end of the test, undeploy the secrets using Terraform
	defer test_structure.RunTestStage(t, "destroy", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

		terraform.Destroy(t, terraformOptions)
	})

	// Provision the secrets using Terraform
	test_structure.RunTestStage(t, "apply", func() {
		awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "eu-west-1"}, nil)
		test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)
		deployUsingTerraform(t, awsRegion, workingDir)
	})

	// Validate that the secrets are configured properly
	test_structure.RunTestStage(t, "validate", func() {
		validateSecretsContainSecrets(t, workingDir)
	})
}

// Deploy the secrets-manager example using Terraform
func deployUsingTerraform(t *testing.T, awsRegion string, workingDir string) {
	// A unique ID we can use to namespace resources so we don't clash with anything already in the AWS account or
	// tests running in parallel
	uniqueID := random.UniqueId()

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"random_id": uniqueID,
			"region":    awsRegion,
		},
	})

	// Save the Terraform Options struct, instance name, and instance text so future test stages can use it
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}

// Validate that the Secret created contains the values as expected
func validateSecretsContainSecrets(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	secret_arns := terraform.OutputList(t, terraformOptions, "secret_arns")

	// Check that two secrets were created
	assert.Len(t, secret_arns, 2)

	// Check that each of the secrets can be retrieved
	for _, arn := range secret_arns {
		secret := aws.GetSecretValue(t, awsRegion, arn)
		logger.Log(t, secret)

		// Check that the keys all exist in the secret

	}

	// Run `terraform output` to get the value of an output variable
	secret_arn_references := terraform.OutputList(t, terraformOptions, "secret_arn_references")

	// Ensure the secret_arn_references format is as expected
	assert.Len(t, secret_arn_references, 4)
}
