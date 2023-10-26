package modules

import (
	"context"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
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

	// Create mongodb client
	_, err := mongo.Connect(context.TODO(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		t.Fatalf("Failed to connect to MongoDB: %v", err)
	}

	// CASE: MongoDB Cluster outputs are correct

	// CASE: VPC Peering configured properly

	// CASE: Notifications are configured correctly

	// CASE: Backups are configured correctly
}
