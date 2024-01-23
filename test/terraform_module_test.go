package test

import (
	"fmt"
	"testing"

	"github.com/Cyber4All/terraform-cyber4all-catalog/test/modules"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

type TestCase struct {
	name            string
	workingDir      string
	genTestDataFunc func(t *testing.T, workingDir string)
	validateFunc    func(t *testing.T, workingDir string)
}

// This test suite deploys the resource in the examples folder using Terraform, and then validates the deployed
// The test is broken into "stages" so you can skip stages by setting environment variables (e.g.,
// skip stage "apply" by setting the environment variable "SKIP_apply=true"), which speeds up iteration when
// running this test over and over again locally.
func TestExamplesForTerraformModules(t *testing.T) {
	/**
	 * The TestCases are broken up into groups. Each group's tests will run in parallel, but the groups will run
	 * sequentially. This is to prevent the tests exhausting the AWS quotas, notably the VPC quota (5 per region).
	 *
	 * To optimize the runtime of the tests, the tests should be sorted as follows:
	 * 1. Tests that do not require a VPC (or any other resource that has a limited quota)
	 * 2. Tests that require a VPC
	 *   a. Longest running tests
	 *   b. Shortest running tests
	 *
	 * A comment should be added that denotes the estimated runtime of the test and any limited resources that the test
	 * requires to run.
	 */
	tests := [][]TestCase{
		{
			// mongodb-cluster: Deploy and validate a MongoDB cluster. (~686.96s)
			// This test requires a VPC.
			{
				name:            "mongodb-cluster",
				workingDir:      "../examples/deploy-mongodb-cluster",
				genTestDataFunc: modules.DeployMongoDBCluster,
				validateFunc:    modules.ValidateMongoDBCluster,
			},

			// ecs_service: Deploy and validate an ECS service. (~912s)
			// This test requires a VPC.
			{
				name:            "ecs service",
				workingDir:      "../examples/deploy-ecs-service",
				genTestDataFunc: modules.DeployEcsServiceUsingTerraform,
				validateFunc:    modules.ValidateEcsService,
			},

			// ecs-cluster: Deploy and validate an ECS cluster. (~313s)
			// This test requires a VPC.
			{
				name:            "ecs-cluster",
				workingDir:      "../examples/deploy-ecs-cluster",
				genTestDataFunc: modules.DeployEcsClusterUsingTerraform,
				validateFunc:    modules.ValidateEcsCluster,
			},

			// alb-https: Deploy and validate an Application Load Balancer with HTTPS. (~268s)
			// This test requires a VPC.
			{
				name:            "alb",
				workingDir:      "../examples/deploy-alb",
				genTestDataFunc: modules.DeployAlb,
				validateFunc:    modules.ValidateAlbHttps,
			},

			// vpc: Deploy and validate a VPC. (~100s)
			// This test requires a VPC.
			{
				name:            "vpc",
				workingDir:      "../examples/deploy-vpc",
				genTestDataFunc: modules.DeployVpcUsingTerraform,
				validateFunc:    modules.ValidateVpc,
			},
		},
	}

	for _, tests := range tests {
		runTest(t, tests)
	}
}

func runTest(t *testing.T, tests []TestCase) {
	// Run tests in parallel
	for _, tt := range tests {
		workingDir := tt.workingDir
		genTestDataFunc := tt.genTestDataFunc
		validateFunc := tt.validateFunc
		t.Run(tt.name, func(t *testing.T) {

			// At the end of the test, undeploy the resources using Terraform
			defer test_structure.RunTestStage(t, "destroy", func() {
				terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
				terraform.Destroy(t, terraformOptions)
				test_structure.CleanupTestDataFolder(t, workingDir)
			})

			// Provision the secrets using Terraform
			test_structure.RunTestStage(t, "apply", func() {
				// Check if .test-data exists
				// If it does not exist, generate the test data
				if !test_structure.IsTestDataPresent(t, fmt.Sprintf("%s/.test-data/TerraformOptions.json", workingDir)) {
					genTestDataFunc(t, workingDir)
				}

				// Get the Terraform Options saved
				terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

				// Deploy the cluster
				terraform.InitAndApply(t, terraformOptions)
			})

			// Validate that the secrets are configured properly
			test_structure.RunTestStage(t, "validate", func() {
				validateFunc(t, workingDir)
			})
		})
	}
}
