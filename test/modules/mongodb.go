package modules

import (
	"context"
	"encoding/json"
	"os"
	"testing"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"go.mongodb.org/atlas-sdk/v20231001002/admin"
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

	// Get the public key and private key from SecretsManager to connect to the MongoDB SDK
	secretArn := os.Getenv("MONGODB_SECRET_ARN")
	secretString := aws.GetSecretValue(t, "us-east-1", secretArn)
	var keys struct {
		PrivateKey string `json:"private_key"`
		PublicKey  string `json:"public_key"`
	}
	assert.NotEmpty(t, secretString, "Secret string is empty")

	err := json.Unmarshal([]byte(secretString), &keys)
	assert.NoError(t, err, "Error when unmarshalling secret string")

	// Connect to MongoDB SDK
	apiKey := keys.PublicKey
	apiSecret := keys.PrivateKey
	sdk, err := admin.NewClient(admin.UseDigestAuth(apiKey, apiSecret))
	assert.NoError(t, err, "Error when creating MongoDB SDK client")

	// CASE: MongoDB Security outputs are correct
	// Get the peering route table ids
	peeringRouteTableIDs := terraform.OutputList(t, terraformOptions, "peering_route_table_ids")
	authorizedIamUsers := terraform.OutputList(t, terraformOptions, "authorized_iam_users")
	authorizedIamRoles := terraform.OutputList(t, terraformOptions, "authorized_iam_roles")

	// Assert there is one peering route table id
	assert.Equal(t, 1, len(peeringRouteTableIDs), "Expected 1 peering route table id, got %d", len(peeringRouteTableIDs))

	// Assert there are two authorized IAM users
	assert.Equal(t, 2, len(authorizedIamUsers), "Expected 2 authorized IAM users, got %d", len(authorizedIamUsers))

	// Assert there is one authorized IAM role
	assert.Equal(t, 1, len(authorizedIamRoles), "Expected 1 authorized IAM role, got %d", len(authorizedIamRoles))

	// CASE: VPC Peering configured properly
	assertPeeringConnectionConfigured(t, sdk, peeringRouteTableIDs[0])
}

func assertPeeringConnectionConfigured(t *testing.T, sdk *admin.APIClient, peeringRouteTableID string) {
	// Get the group id
	groups, _, err := sdk.ProjectsApi.ListProjects(context.Background()).Execute()
	assert.NoError(t, err, "Error when getting projects")
	groupID := groups.Results[0].Id

	// Get Peering Connection
	peeringCons, _, err := sdk.NetworkPeeringApi.ListPeeringConnections(context.Background(), *groupID).Execute()
	assert.NoError(t, err, "Error when getting peering connections")
	assert.Len(t, peeringCons.Results, 1, "Expected 1 peering connection, got %d", len(peeringCons.Results))

	// Get Peering Connection Details
	peerID := peeringCons.Results[0].Id
	peer, _, err := sdk.NetworkPeeringApi.GetPeeringConnection(context.TODO(), *groupID, *peerID).Execute()
	assert.NoError(t, err, "Error when getting peering connection")

	// Get Route Table
	// Create aws session
	session, err := session.NewSession()
	assert.NoError(t, err, "Error creating AWS session")

	// Create Client
	ec2Client := ec2.New(session, &aws_sdk.Config{Region: aws_sdk.String("us-east-1")})

	// Describe Route Table
	prt, err := ec2Client.DescribeRouteTables(&ec2.DescribeRouteTablesInput{
		RouteTableIds: []*string{
			aws_sdk.String(peeringRouteTableID),
		},
	})

	// Assert that route table exists
	assert.NoError(t, err, "Error when describing route table")
	assert.Len(t, prt.RouteTables, 1, "Expected 1 route table, got %d", len(prt.RouteTables))

	// Assert that vpc in route table matches vpc in peering connection
	found := false
	for _, route := range prt.RouteTables[0].Routes {
		if *route.DestinationCidrBlock == *peer.RouteTableCidrBlock {
			found = true
		}
	}
	assert.True(t, found, "Expected route table to have route to peering connection")
}
