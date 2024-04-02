package modules

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func DeployMongoDBSecurityUsingTerraform(t *testing.T, workingDir string) {
	// Generate a random id
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: workingDir,
		Vars:         map[string]interface{}{},
	})

	// Save the options so later test stages can use them
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
}

// ValidateMongoDBSecurity validates the MongoDB Security Terraform module.
// It loads the Terraform options, gets the public and private keys from SecretsManager to connect to the MongoDB SDK,
// creates an admin client, and validates the outputs and VPC peering configuration.
// MONGODB_SECRET_ARN environment variable must be set to the ARN of the secret containing the MongoDB public and private keys.
func ValidateMongoDBSecurity(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	// CASE: MongoDB Security outputs are correct
	// Get the peering route table ids
	authorizedIamUsers := terraform.OutputList(t, terraformOptions, "authorized_iam_users")
	authorizedIamRoles := terraform.OutputList(t, terraformOptions, "authorized_iam_roles")

	// Assert there are two authorized IAM users
	assert.Equal(t, 2, len(authorizedIamUsers), "Expected 2 authorized IAM users, got %d", len(authorizedIamUsers))

	// Assert there is one authorized IAM role
	assert.Equal(t, 1, len(authorizedIamRoles), "Expected 1 authorized IAM role, got %d", len(authorizedIamRoles))

}
