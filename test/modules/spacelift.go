package modules

import (
	"fmt"
	"strconv"
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
	randomID := strings.ToLower(terraformOptions.Vars["random_id"].(string))

	// Dependency mappings are correct
	// number of dependencies are correct
	numDep, err := strconv.Atoi(terraform.Output(t, terraformOptions, "number_of_dependencies"))
	assert.NoError(t, err, "Error converting number_of_dependencies to int")
	assert.Equal(t, numDep, 0, "Expected 0 dependency, got %d", numDep)

	// number of output references are correct
	numOutRef, err := strconv.Atoi(terraform.Output(t, terraformOptions, "number_of_output_references"))
	assert.NoError(t, err, "Error converting number_of_output_references to int")
	assert.Equal(t, numOutRef, 0, "Expected 0 output reference, got %d", numOutRef)

	// stack_id is correct
	stackID := terraform.Output(t, terraformOptions, "stack_id")
	assert.Equalf(t, stackID, fmt.Sprintf("test-admin-stack%s", randomID), "Expected stack id to be test-admin-stack%s, got %s", randomID, stackID)

	// stack_iam_role_id is correct
	roleName := terraform.Output(t, terraformOptions, "stack_iam_role_id")
	assert.Equalf(t, roleName, fmt.Sprintf("test-admin-stack%s-role", randomID), "Expected role name to be test-admin-stack%s-role, got %s", randomID, roleName)

	// stack_iam_role_arn is correct
	// ==> Assert that the role arn is: arn:aws:iam::${local.account_id}:role${local.iam_role_path}${local.iam_role_name}
	roleArn := terraform.Output(t, terraformOptions, "stack_iam_role_arn")
	assert.Truef(t, strings.HasSuffix(roleArn, fmt.Sprintf("role/spacelift/test-admin-stack%s-role", randomID)), "The role arn is not correct. Expected: %s, got: %s", fmt.Sprintf("role/spacelift/test-admin-stack%s-role", randomID), roleArn)

	// stack_iam_role_policy_arns are correct
	policyArns := terraform.OutputList(t, terraformOptions, "stack_iam_role_policy_arns")
	assert.Equal(t, len(policyArns), 1, "Expected 1 policy arn, got %d", len(policyArns))
	expectedPolicyArn := "arn:aws:iam::aws:policy/AdministratorAccess"
	assert.Equalf(t, policyArns[0], expectedPolicyArn, "The policy arn is not correct. Expected: %s, got: %s", expectedPolicyArn, policyArns[0])

	// Check that the IAM role is created in AWS
	_, err = aws.NewIamClient(t, "us-east-1").GetRole(&iam.GetRoleInput{
		RoleName: &roleName,
	})

	assert.NoError(t, err, "The IAM role was not created correctly")
}
