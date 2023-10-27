package modules

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"testing"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"go.mongodb.org/atlas-sdk/v20231001002/admin"
)

func DeployMongoDBCluster(t *testing.T, workingDir string) {
	// Get the role arn from env
	roleArn := os.Getenv("TF_VAR_mongodb_role_arn")
	// Generate a random id
	randomID := random.UniqueId()
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"mongodb_role_arn": roleArn,
			"random_id":        randomID,
		},
	})

	// Save the options so later test stages can use them
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
}

func ValidateMongoDBCluster(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	// Get the mongodb base uri
	mongoURI := terraform.Output(t, terraformOptions, "cluster_mongodb_base_uri")
	// Get the cluster id
	clusterID := terraform.Output(t, terraformOptions, "cluster_id")
	// Get the peering route table ids
	peeringRouteTableIDs := terraform.OutputList(t, terraformOptions, "cluster_peering_route_table_ids")
	// Assert there is one peering route table id
	assert.Equal(t, 1, len(peeringRouteTableIDs), "Expected 1 peering route table id, got %d", len(peeringRouteTableIDs))

	// Get Cluster State
	clusterState := terraform.Output(t, terraformOptions, "cluster_state")
	// Validate the cluster state is IDLE or CREATING
	assert.Contains(t, []string{"IDLE", "CREATING"}, clusterState, "Cluster state is not IDLE or CREATING")

	fmt.Println("MongoDB Cluster URI: ", mongoURI)
	fmt.Println("MongoDB Cluster ID: ", clusterID)
	fmt.Println("MongoDB Cluster State: ", clusterState)
	fmt.Println("MongoDB Cluster Peering Route Table IDs: ", peeringRouteTableIDs)

	// Get public key and private key from secrets manager
	// TODO: Get Secrets ARN
	secretString := aws.GetSecretValue(t, "us-east-1", "")
	var keys struct {
		PrivateKey string `json:"private_key"`
		PublicKey  string `json:"public_key"`
	}

	err := json.Unmarshal([]byte(secretString), &keys)
	if err != nil {
		t.Fatalf("Error when unmarshalling json: %v", err)
	}

	apiKey := keys.PublicKey
	apiSecret := keys.PrivateKey
	// Create admin client
	sdk, err := admin.NewClient(admin.UseDigestAuth(apiKey, apiSecret))
	if err != nil {
		log.Fatalf("Error when instantiating new client: %v", err)
	}

	// CASE: MongoDB Cluster outputs are correct

	// CASE: VPC Peering configured properly
	// https://cloud.mongodb.com/api/atlas/v2/groups/{groupId}/containers/all
	groups, _, err := sdk.ProjectsApi.ListProjects(context.Background()).Execute()
	assert.NoError(t, err, "Error when getting projects")
	groupID := groups.Results[0].Id

	peeringCons, _, err := sdk.NetworkPeeringApi.ListPeeringConnections(context.Background(), *groupID).Execute()
	assert.NoError(t, err, "Error when getting peering connections")
	assert.Len(t, peeringCons.Results, 1, "Expected 1 peering connection, got %d", len(peeringCons.Results))

	peerID := peeringCons.Results[0].Id
	peer, _, err := sdk.NetworkPeeringApi.GetPeeringConnection(context.TODO(), *groupID, *peerID).Execute()
	assert.NoError(t, err, "Error when getting peering connection")

	// Get Route Table
	// Create aws session
	session, err := session.NewSession()
	assert.NoError(t, err, "Error creating AWS session")

	// Create Client
	ec2Client := ec2.New(session, &aws_sdk.Config{Region: aws_sdk.String("us-east-1")})
	prt, err := ec2Client.DescribeRouteTables(&ec2.DescribeRouteTablesInput{
		RouteTableIds: []*string{
			aws_sdk.String(peeringRouteTableIDs[0]),
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
	// CASE: Backups are configured correctly
	// https://cloud.mongodb.com/api/atlas/v2/groups/{groupId}/backup/exportBuckets
}
