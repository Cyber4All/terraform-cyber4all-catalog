package modules

import (
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Deploy the secrets-manager example using Terraform
func DeployUsingTerraform(t *testing.T, workingDir string) {
	// A unique ID we can use to namespace resources so we don't clash with anything already in the AWS account or
	// tests running in parallel
	uniqueID := random.UniqueId()
	secretKey := fmt.Sprint("secret_key_", uniqueID)
	secretValue := fmt.Sprint("secret_value_", uniqueID)

	// Get random aws region
	// Get a random AWS region
	awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "us-east-2"}, nil)
	test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"random_id":    uniqueID,
			"region":       awsRegion,
			"secret_key":   secretKey,
			"secret_value": secretValue,
		},
	})

	// Save the Terraform Options struct, instance name, and instance text so future test stages can use it
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}

// Validate that the Secret created contains the values as expected
func ValidateSecretsContainSecrets(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	// Check that two secrets were created
	secret_arns := assertSecretsArnsAreCreated(t, terraformOptions)

	// Assert that the two secret names are correct
	assertSecretsAreNamedCorrectly(t, terraformOptions)

	secretKey := terraformOptions.Vars["secret_key"].(string)
	secretValue := terraformOptions.Vars["secret_value"].(string)

	// Check that each of the secrets can be retrieved
	assertSecretsHaveCorrectPrefix(t, secret_arns, awsRegion, secretKey, secretValue)

	// Check that the secret_arn_references are formatted correctly
	assertSecretArnReferencesAreFormattedCorrectly(t, terraformOptions, secret_arns, secretKey)
}

func assertSecretsArnsAreCreated(t *testing.T, terraformOptions *terraform.Options) []string {
	secret_arns := terraform.OutputList(t, terraformOptions, "secret_arns")
	assert.Len(t, secret_arns, 2)

	return secret_arns
}

func assertSecretsAreNamedCorrectly(t *testing.T, terraformOptions *terraform.Options) {
	names := terraform.OutputList(t, terraformOptions, "secret_names")
	assert.Len(t, names, 2)
}

func assertSecretsHaveCorrectPrefix(t *testing.T, secret_arns []string, awsRegion string, secretKey string, secretValue string) {
	for _, arn := range secret_arns {
		var secret map[string]string
		secretStr := aws.GetSecretValue(t, awsRegion, arn)
		json.Unmarshal([]byte(secretStr), &secret)

		// Check that the keys all exist in the secret
		assert.Len(t, secret, 2, "Secret does not contain %d keys. got: %d", 2, len(secret))

		// Check that the keys have the expected prefix
		for k := range secret {
			assert.True(t, strings.HasPrefix(k, secretKey), "Secret key %s does not have prefix %s", k, secretKey)

			value := secret[k]
			assert.True(t, strings.HasPrefix(value, secretValue), "Secret value %s does not have prefix %s", value, secretValue)
		}
	}
}

func assertSecretArnReferencesAreFormattedCorrectly(t *testing.T, terraformOptions *terraform.Options, secret_arns []string, secretKey string) {
	// Run `terraform output` to get the value of an output variable
	secret_arn_references := terraform.OutputList(t, terraformOptions, "secret_arn_references")

	// Ensure the secret_arn_references format is as expected
	assert.Len(t, secret_arn_references, 4, "Expected %d secret_arn_references, got: %d", 4, len(secret_arn_references))

	// Validate the format of the secret_arn_references matches: secret_arn:secret_key::
	for _, arn_ref := range secret_arn_references {
		assert.True(t, strings.HasSuffix(arn_ref, "::"), "Secret arn reference %s does not end with ::", arn_ref)
		// Assert that the secret arn reference matches one of the secret arns
		correct_arn := false
		var prefix string
		for _, arn := range secret_arns {
			if strings.HasPrefix(arn_ref, arn) {
				correct_arn = true
				prefix = arn
			}
		}
		assert.True(t, correct_arn, "Secret arn reference %s does not match any of the secret arns", arn_ref)
		// Remove prefix and suffix to get the secret key
		key := strings.TrimPrefix(arn_ref, fmt.Sprintf("%s:", prefix))
		key = strings.TrimSuffix(key, "::")

		// Assert that the secret key starts with the expected secret key (Secret Key ends with a number for uniqueness)
		assert.True(t, strings.HasPrefix(key, secretKey), "Secret key %s does not have prefix %s", key, secretKey)
	}
}
