package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func destroyDeployedResource(t *testing.T, workingDir string) {
	test_structure.RunTestStage(t, "destroy", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

		terraform.Destroy(t, terraformOptions)
	})
}

func getAndSaveRandomRegion(t *testing.T, workingDir string) string {
	awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "eu-west-1"}, nil)
	test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)
	return awsRegion
}
