package modules

import (
	"fmt"
	"strconv"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// DeployVpcUsingTerraform deploys the Terraform code in the given working dir and returns the Terraform output
func DeployVpcUsingTerraform(t *testing.T, workingDir string) {
	// Get a random AWS region
	awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "us-east-2"}, nil)
	test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"region": awsRegion,
		},
	})

	// Save the options so later test stages can use them
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
}

// ValidateVpc validates the VPC
func ValidateVpc(t *testing.T, workingDir string) {
	// Load the terraform options
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	// Check that the VPC exists
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	vpc := aws.GetVpcById(t, vpcID, awsRegion)
	assert.NotNil(t, vpc, "Expected VPC to exist")

	// Get the number of availability zones in the region
	azs := aws.GetAvailabilityZones(t, awsRegion)
	numAzs := len(azs)
	// Assert that the VPC has the correct number of subnets
	publicSubnets := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	assert.Equal(t, numAzs, len(publicSubnets), "Expected %d Public Subnets, got %d", numAzs, len(publicSubnets))

	// Assert that the Public CIDR blocks are computed correctly
	publicCidrBlocks := terraform.OutputList(t, terraformOptions, "public_subnet_cidr_blocks")
	assert.Equal(t, numAzs, len(publicCidrBlocks), "Expected %d Public CIDR Blocks, got %d", numAzs, (publicCidrBlocks))

	// Should have format 10.0.*.0/24
	for i, cidr := range publicCidrBlocks {
		assert.Equal(t, fmt.Sprintf("10.0.%d.0/24", i+1), cidr)
	}
	// Assert that the Public Route tables direct traffic to the Internet Gateway
	// TODO

	// Assert that the Public NACL is configured Correctly
	// TODO

	// Assert Number of Private Subnets is correct
	privateSubnets := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	assert.Equal(t, numAzs, len(privateSubnets), "Expected %d Private Subnets, got %d", numAzs, len(privateSubnets))
	// Assert that the Private CIDR blocks are computed correctly
	privateCidrBlocks := terraform.OutputList(t, terraformOptions, "private_subnet_cidr_blocks")
	assert.Equal(t, numAzs, len(privateCidrBlocks), "Expected %d Private CIDR Blocks, got %d", numAzs, (privateCidrBlocks))

	// Should have format 10.0.*.0/24 Picking up from the end of the private subnets
	for i, cidr := range privateCidrBlocks {
		assert.Equal(t, fmt.Sprintf("10.0.%d.0/24", numAzs+i+1), cidr)
	}
	// Assert that the Private Route tables direct traffic to the NAT Gateway
	// TODO

	// Assert that the Private NACL is configured Correctly
	// TODO

	// Assert that the Number of NAT Gateways is correct
	natCount, err := strconv.ParseInt(terraform.Output(t, terraformOptions, "num_nat_gateways"), 10, 0)
	assert.NoError(t, err, "Error parsing number of NAT Gateways")
	assert.Equal(t, int64(1), natCount, "Expected 1 NAT Gateway, got %d", natCount)
}
