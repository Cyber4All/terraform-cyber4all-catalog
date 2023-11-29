package modules

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/Cyber4All/terraform-cyber4all-catalog/test/util"
	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/machinebox/graphql"
	"github.com/stretchr/testify/assert"
)

type Stack struct {
	ID             string `json:"id"`
	Administrative bool   `json:"administrative"`
	Blocked        bool   `json:"blocked"`
	Name           string `json:"name"`
	State          string `json:"state"`
}

//{"administrative":true,"blocked":true,"id":"test-admin-stack0a3rnz","name":"test-admin-stack0a3Rnz","state":"PREPARING"}

// DeploySpaceliftAdminStack deploys the spacelift admin stack using terraform
func DeploySpaceliftAdminStack(t *testing.T, workingDir string) {
	// Generate a unique ID
	uniqueID := strings.ToLower(random.UniqueId())

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

	token := getSpaceLiftToken(t)
	// Get the stacks from spacelift
	stacks := getSpaceLiftStacks(t, token)

	// Filter out stacks that are not part of this test
	filteredStacks := util.Filter(&stacks, func(stack Stack) bool {
		return strings.HasPrefix(stack.Name, "test") && strings.HasSuffix(stack.Name, randomID)
	})

	// Assert that all stacks are FINISHED
	// Set a timeout of 5 minutes
	timeout := time.Now().Add(20 * time.Minute)
	complete := false

	fmt.Println("Number of filtered stacks: ", len(*filteredStacks))
	for time.Now().Before(timeout) && !complete {
		if util.Every(filteredStacks, func(stack Stack) bool {
			return stack.State == "FINISHED"
		}) {
			complete = true
			break
		}
		// Wait 10 seconds before checking again
		time.Sleep(10 * time.Second)
		stacks = getSpaceLiftStacks(t, token)
		filteredStacks = util.Filter(&stacks, func(stack Stack) bool {
			return strings.HasPrefix(stack.Name, "test") && strings.HasSuffix(stack.Name, randomID)
		})
		fmt.Println("Stacks: ", *filteredStacks)
	}

	assert.True(t, complete, "Stacks did not finish within the timeout period of 5 minutes")

	// There should be 3 stacks, admin, vpc, and ecs-cluster
	assert.Equal(t, len(*filteredStacks), 3, "Expected 3 stacks, got %d", len(*filteredStacks))
}

func getSpaceLiftToken(t *testing.T) string {
	// Get Secret Key & Access Key
	smClient := aws.NewSecretsManagerClient(t, "us-east-1")
	secret, err := smClient.GetSecretValue(&secretsmanager.GetSecretValueInput{
		SecretId: aws_sdk.String("arn:aws:secretsmanager:us-east-1:353964526231:secret:spacelift/sandbox-ifw40J"),
	})
	assert.NoError(t, err, "Error getting secret key from secrets manager")

	var secretData map[string]string
	err = json.Unmarshal([]byte(*secret.SecretString), &secretData)
	assert.NoError(t, err, "Error unmarshalling secret string")

	secretKey := secretData["api_key_secret"]
	accessKey := secretData["api_key_id"]

	mutation := `
			mutation GetJWT($id: ID!, $secret: String!) {
				apiKeyUser(id: $id, secret: $secret) {
					jwt
				}
			}
		`

	data := makeGraphRequest(t, mutation, &map[string]interface{}{
		"id":     accessKey,
		"secret": secretKey,
	}, nil)

	if data["errors"] != nil {
		t.Fatalf("Error getting token from spacelift api: %v", data["errors"])
	}

	dataJson, err := json.Marshal(data)
	assert.NoError(t, err, "Error marshalling data")

	var token struct {
		ApiKeyUser struct {
			Jwt string `json:"jwt"`
		} `json:"apiKeyUser"`
	}

	err = json.Unmarshal(dataJson, &token)
	assert.NoError(t, err, "Error unmarshalling data")

	return token.ApiKeyUser.Jwt
}

func makeGraphRequest(t *testing.T, query string, variables *map[string]interface{}, bearer *string) map[string]interface{} {
	graphClient := graphql.NewClient("https://cyber4all.app.spacelift.io/graphql")

	req := graphql.NewRequest(query)

	if variables != nil {
		for key, value := range *variables {
			req.Var(key, value)
		}
	}

	if bearer != nil {
		req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", *bearer))
	}

	ctx := context.Background()

	var data map[string]interface{}
	if err := graphClient.Run(ctx, req, &data); err != nil {
		t.Fatalf("Error making graphql request: %v", err)
	}

	return data
}

func getSpaceLiftStacks(t *testing.T, token string) []Stack {
	query := `
		query {
			stacks {
				id
				administrative
				blocked
				name
				state
			}
		}
		`

	data := makeGraphRequest(t, query, nil, &token)

	dataJson, err := json.Marshal(data["stacks"])
	assert.NoError(t, err, "Error marshalling data")

	var stacks []Stack
	err = json.Unmarshal(dataJson, &stacks)
	assert.NoError(t, err, "Error unmarshalling data")

	return stacks
}
