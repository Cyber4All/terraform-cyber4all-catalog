package test

import (
	"testing"

	"github.com/Cyber4All/terraform-cyber4all-catalog/test/modules"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// This test suite deploys the resource in the examples folder using Terraform, and then validates the deployed
// The test is broken into "stages" so you can skip stages by setting environment variables (e.g.,
// skip stage "apply" by setting the environment variable "SKIP_apply=true"), which speeds up iteration when
// running this test over and over again locally.
func TestExamplesForTerraformModules(t *testing.T) {
	tests := []struct {
		name         string
		workingDir   string
		deployFunc   func(t *testing.T, workingDir string, awsRegion string)
		validateFunc func(t *testing.T, workingDir string)
	}{
		{
			name:         "ecs-cluster",
			workingDir:   "../examples/ecs-cluster",
			deployFunc:   modules.DeployEcsClusterUsingTerraform,
			validateFunc: modules.ValidateEcsCluster,
		},
		{
			name:         "secrets-manager",
			workingDir:   "../examples/secrets-manager",
			deployFunc:   modules.DeployUsingTerraform,
			validateFunc: modules.ValidateSecretsContainSecrets,
		},
	}

	// Run tests in parallel
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// At the end of the test, undeploy the secrets using Terraform
			defer destroyDeployedResource(t, tt.workingDir)

			// Get a random AWS region
			awsRegion := getAndSaveRandomRegion(t, tt.workingDir)

			// Provision the secrets using Terraform
			test_structure.RunTestStage(t, "apply", func() {
				tt.deployFunc(t, tt.workingDir, awsRegion)
			})

			// Validate that the secrets are configured properly
			test_structure.RunTestStage(t, "validate", func() {
				tt.validateFunc(t, tt.workingDir)
			})
		})
	}
}
