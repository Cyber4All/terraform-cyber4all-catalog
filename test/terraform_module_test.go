package test

import (
	"fmt"
	"testing"

	"github.com/Cyber4All/terraform-cyber4all-catalog/test/modules"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// This test suite deploys the resource in the examples folder using Terraform, and then validates the deployed
// The test is broken into "stages" so you can skip stages by setting environment variables (e.g.,
// skip stage "apply" by setting the environment variable "SKIP_apply=true"), which speeds up iteration when
// running this test over and over again locally.
func TestExamplesForTerraformModules(t *testing.T) {
	tests := []struct {
		name            string
		workingDir      string
		genTestDataFunc func(t *testing.T, workingDir string)
		validateFunc    func(t *testing.T, workingDir string)
	}{
		// {
		// 	name:            "ecs-cluster",
		// 	workingDir:      "../examples/ecs-cluster",
		// 	genTestDataFunc: modules.DeployEcsClusterUsingTerraform,
		// 	validateFunc:    modules.ValidateEcsCluster,
		// },
		// {
		// 	name:            "secrets-manager",
		// 	workingDir:      "../examples/secrets-manager",
		// 	genTestDataFunc: modules.DeployUsingTerraform,
		// 	validateFunc:    modules.ValidateSecretsContainSecrets,
		// },
		// {
		// 	name:            "alb https",
		// 	workingDir:      "../examples/deploy-alb",
		// 	genTestDataFunc: modules.DeployAlb,
		// 	validateFunc:    modules.ValidateAlbHttps,
		// },
		{
			name:            "alb w/o https",
			workingDir:      "../examples/deploy-alb-wo-https",
			genTestDataFunc: modules.DeployAlb,
			validateFunc:    modules.ValidateAlbNoHttps,
		},
	}

	// Run tests in parallel
	for _, tt := range tests {
		workingDir := tt.workingDir
		genTestDataFunc := tt.genTestDataFunc
		validateFunc := tt.validateFunc
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
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
