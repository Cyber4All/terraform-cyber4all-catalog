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
	tests := [][]TestCase{
		{
			{
				name:            "ecs-cluster",
				workingDir:      "../examples/ecs-cluster",
				genTestDataFunc: modules.DeployEcsClusterUsingTerraform,
				validateFunc:    modules.ValidateEcsCluster,
			},
			{
				name:            "secrets-manager",
				workingDir:      "../examples/secrets-manager",
				genTestDataFunc: modules.DeployUsingTerraform,
				validateFunc:    modules.ValidateSecretsContainSecrets,
			},
			{
				name:            "alb https",
				workingDir:      "../examples/deploy-alb",
				genTestDataFunc: modules.DeployAlb,
				validateFunc:    modules.ValidateAlbHttps,
			},
			{
				name:            "alb w/o https",
				workingDir:      "../examples/deploy-alb-wo-https",
				genTestDataFunc: modules.DeployAlb,
				validateFunc:    modules.ValidateAlbNoHttps,
			},
		},
		// VPC TESTS
		{
			{
				name:            "vpc",
				workingDir:      "../examples/deploy-vpc",
				genTestDataFunc: modules.DeployVpcUsingTerraform,
				validateFunc:    modules.ValidateVpc,
			},
			{
				name:            "vpc-partial-azs",
				workingDir:      "../examples/deploy-vpc-partial-azs",
				genTestDataFunc: modules.DeployVpcUsingTerraform,
				validateFunc:    modules.ValidateVpc,
			},
			{
				name:            "vpc-public-only",
				workingDir:      "../examples/deploy-vpc-public-only",
				genTestDataFunc: modules.DeployVpcUsingTerraform,
				validateFunc:    modules.ValidateOnlyPublicSubnets,
			},
			{
				name:            "vpc-wo-nat",
				workingDir:      "../examples/deploy-vpc-wo-nat",
				genTestDataFunc: modules.DeployVpcUsingTerraform,
				validateFunc:    modules.ValidateVpcNoNat,
			},
		},
		{
			name:            "ecs service",
			workingDir:      "../examples/deploy-ecs-service",
			genTestDataFunc: modules.DeployEcsServiceUsingTerraform,
			validateFunc:    modules.ValidateEcsService,
		},
	}

	for _, tests := range tests {
		runTest(t, tests)
	}
}

func runTest(t *testing.T, tests []TestCase) {
	// Run tests in parallel
	for i, tt := range tests {
		workingDir := tt.workingDir
		genTestDataFunc := tt.genTestDataFunc
		validateFunc := tt.validateFunc
		t.Run(tt.name, func(t *testing.T) {
			// If not the last test, run in parallel
			if i != len(tests)-1 {
				t.Parallel()
			}
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
