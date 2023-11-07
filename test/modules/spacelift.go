package modules

import (
	"fmt"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// DeploySpaceliftAdminStack deploys the spacelift admin stack using terraform
func DeploySpaceliftAdminStack(t *testing.T, workingDir string) {
	// Generate a unique ID
	uniqueID := random.UniqueId()

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"random_id": uniqueID,
		},
	})

	// Save the options so later test stages can use them
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
}

// ValidateSpaceliftAdminStack validates the spacelift admin stack
func ValidateSpaceliftAdminStack(t *testing.T, workingDir string) {
	// Get the terraform options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	randomID := terraformOptions.Vars["random_id"].(string)
	// Check that the outputs are set correctly

	// Dependency mappings are correct
	// number of dependencies are correct
	// number of output references are correct
	// stack_id is correct
	// stack_iam_role_id is correct
	// stack_iam_role_arn is correct
	// ==> Assert that the role arn is: arn:aws:iam::${local.account_id}:role${local.iam_role_path}${local.iam_role_name}
	roleArn := terraform.Output(t, terraformOptions, "stack_iam_role_arn")
	// Get the last part of the role arn
	role := strings.Split(roleArn, ":")[5]
	expectedRole := fmt.Sprintf("role/spacelift/test-admin-stack%s", randomID)
	assert.Equalf(t, role, expectedRole, "The role arn is not correct. Expected: %s, got: %s", expectedRole, role)
	// stack_iam_role_policy_arns are correct

	// Check that the IAM role is created in AWS
	_, err := aws.NewIamClient(t, "us-east-1").GetRole(&iam.GetRoleInput{
		RoleName: &role,
	})

	assert.NoError(t, err, "The IAM role was not created correctly")
}
