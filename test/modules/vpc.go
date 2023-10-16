package modules

import (
	"fmt"
	"strconv"
	"testing"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
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

func ValidateOnlyPublicSubnets(t *testing.T, workingDir string) {
	// Load the terraform options
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	// Create aws session
	session, err := session.NewSession()
	assert.NoError(t, err, "Error creating AWS session")

	// Create Client
	ec2Client := ec2.New(session, &aws_sdk.Config{Region: aws_sdk.String(awsRegion)})

	// Check that the VPC exists
	vpcID := assertVpcExists(t, terraformOptions, awsRegion)

	// Assert that the VPC has the correct number of subnets
	numAzs, err := strconv.Atoi(terraform.Output(t, terraformOptions, "num_availability_zones"))
	assert.NoError(t, err, "Error converting num_availability_zones to int")
	assertVpcHasCorrectNumberOfSubnets(t, terraformOptions, awsRegion, "public_subnet_ids", numAzs)

	// Assert that the VPC has no private subnets
	subnets, err := ec2Client.DescribeSubnets(&ec2.DescribeSubnetsInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws_sdk.String("vpc-id"),
				Values: []*string{aws_sdk.String(vpcID)},
			},
			{
				Name:   aws_sdk.String("tag:Name"),
				Values: []*string{aws_sdk.String("Private Subnet")},
			},
		},
	})
	assert.NoError(t, err, "Error describing subnets")

	assert.Equal(t, 0, len(subnets.Subnets), "Expected 0 Private Subnets, got %d", len(subnets.Subnets))
}

func ValidateVpcNoNat(t *testing.T, workingDir string) {
	// Load the terraform options
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	// Create aws session
	session, err := session.NewSession()
	assert.NoError(t, err, "Error creating AWS session")

	// Create Client
	ec2Client := ec2.New(session, &aws_sdk.Config{Region: aws_sdk.String(awsRegion)})

	// Check that the VPC exists
	vpcID := assertVpcExists(t, terraformOptions, awsRegion)

	// Assert that the VPC has the correct number of subnets
	numAzs, err := strconv.Atoi(terraform.Output(t, terraformOptions, "num_availability_zones"))
	assert.NoError(t, err, "Error converting num_availability_zones to int")

	assertVpcHasCorrectNumberOfSubnets(t, terraformOptions, awsRegion, "public_subnet_ids", numAzs)

	// Assert that the Public CIDR blocks are computed correctly
	assertPublicCidrBlocksAreCorrect(t, terraformOptions, numAzs)

	// Assert that the Public Route tables direct traffic to the Internet Gateway
	assertPublicRouteTablesHaveCorrectRoutes(t, terraformOptions, ec2Client, vpcID)

	// Assert that the Public NACL is configured Correctly
	acls, err := ec2Client.DescribeNetworkAcls(&ec2.DescribeNetworkAclsInput{})
	assert.NoError(t, err, "Error describing NACLs")

	t.Log(acls)

	// Assert Number of Private Subnets is correct
	assertVpcHasCorrectNumberOfSubnets(t, terraformOptions, awsRegion, "private_subnet_ids", numAzs)

	// Assert that the Private CIDR blocks are computed correctly
	assertCidrBlocksAreCorrect(t, terraformOptions, numAzs)
}

// ValidateVpc validates the VPC
func ValidateVpc(t *testing.T, workingDir string) {
	// Load the terraform options
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	// Create aws session
	session, err := session.NewSession()
	assert.NoError(t, err, "Error creating AWS session")

	// Create Client
	ec2Client := ec2.New(session, &aws_sdk.Config{Region: aws_sdk.String(awsRegion)})

	// Check that the VPC exists
	vpcID := assertVpcExists(t, terraformOptions, awsRegion)

	// Assert that the VPC has the correct number of subnets
	numAzs, err := strconv.Atoi(terraform.Output(t, terraformOptions, "num_availability_zones"))
	assert.NoError(t, err, "Error converting num_availability_zones to int")

	assertVpcHasCorrectNumberOfSubnets(t, terraformOptions, awsRegion, "public_subnet_ids", numAzs)

	// Assert that the Public CIDR blocks are computed correctly
	assertPublicCidrBlocksAreCorrect(t, terraformOptions, numAzs)

	// Assert that the Public Route tables direct traffic to the Internet Gateway
	assertPublicRouteTablesHaveCorrectRoutes(t, terraformOptions, ec2Client, vpcID)

	// Assert Number of Private Subnets is correct
	assertVpcHasCorrectNumberOfSubnets(t, terraformOptions, awsRegion, "private_subnet_ids", numAzs)

	// Assert that the Private CIDR blocks are computed correctly
	assertCidrBlocksAreCorrect(t, terraformOptions, numAzs)

	// Assert that the Private Route tables direct traffic to the NAT Gateway
	assertPrivateRouteTableConfiguredCorrectly(t, terraformOptions, ec2Client, vpcID)
}

func assertPublicRouteTablesHaveCorrectRoutes(t *testing.T, terraformOptions *terraform.Options, ec2Client *ec2.EC2, vpcID string) {
	// Get the Internet Gateway for the VPC
	igtw, err := ec2Client.DescribeInternetGateways(&ec2.DescribeInternetGatewaysInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws_sdk.String("attachment.vpc-id"),
				Values: []*string{aws_sdk.String(vpcID)},
			},
		},
	})
	assert.NoError(t, err, "Error describing Internet Gateways")

	// Assert There are Internet Gateways
	assert.NotEqual(t, 0, len(igtw.InternetGateways), "Expected at least 1 Internet Gateway, got 0")
	// Assert that the Internet Gateway has attachements
	assert.NotEqual(t, 0, len(igtw.InternetGateways[0].Attachments), "Expected at least 1 Internet Gateway Attachment, got 0")
	// Assert that the Internet Gateway is attached to the VPC
	assert.Equal(t, vpcID, *igtw.InternetGateways[0].Attachments[0].VpcId, "Expected Internet Gateway to be attached to VPC %s, got %s", vpcID, *igtw.InternetGateways[0].Attachments[0].VpcId)

	pubrtID := terraform.Output(t, terraformOptions, "public_subnet_route_table_id")

	// Get route table
	rt, err := ec2Client.DescribeRouteTables(&ec2.DescribeRouteTablesInput{
		RouteTableIds: []*string{
			aws_sdk.String(pubrtID),
		},
	})
	assert.NoError(t, err, "Error describing Route Tables")

	// Assert a Route Table was returned
	assert.Equal(t, 1, len(rt.RouteTables), "Expected 1 Route Table, got %d", len(rt.RouteTables))
	igtwID := *igtw.InternetGateways[0].InternetGatewayId
	// Assert that the Public Route table has a route to the Internet Gateway
	found := false
	for _, route := range rt.RouteTables[0].Routes {
		if *route.GatewayId == igtwID {
			found = true
			break
		}
	}
	assert.True(t, found, "Expected Route Table %s to have a route to Internet Gateway %s", pubrtID, igtwID)
}

func assertPrivateRouteTableConfiguredCorrectly(t *testing.T, terraformOptions *terraform.Options, ec2Client *ec2.EC2, vpcID string) {
	prtID := terraform.Output(t, terraformOptions, "private_subnet_route_table_id")
	natgw, err := ec2Client.DescribeNatGateways(&ec2.DescribeNatGatewaysInput{})
	assert.NoError(t, err, "Error describing NAT Gateways")

	// Assert There are NAT Gateways
	assert.NotEqual(t, 0, len(natgw.NatGateways), "Expected at least 1 NAT Gateway, got 0")
	natgwID := ""
	for _, nat := range natgw.NatGateways {
		if nat.State != nil && *nat.State == "available" {
			natgwID = *nat.NatGatewayId
			break
		}
	}
	assert.NotEmpty(t, natgwID, "No NAT Gateway in available state")

	prt, err := ec2Client.DescribeRouteTables(&ec2.DescribeRouteTablesInput{
		RouteTableIds: []*string{
			aws_sdk.String(prtID),
		},
	})
	assert.NoError(t, err, "Error describing Route Tables")

	// Assert a Route Table was returned
	assert.Equal(t, 1, len(prt.RouteTables), "Expected 1 Route Table, got %d", len(prt.RouteTables))
	// Assert that the Private Route table has a route to the NAT Gateway
	found := false
	for _, route := range prt.RouteTables[0].Routes {
		if route.NatGatewayId != nil && *route.NatGatewayId == natgwID {
			found = true
			break
		}
	}
	assert.True(t, found, "Expected Route Table %s to have a route to NAT Gateway %s", prtID, natgwID)
}

func assertPublicCidrBlocksAreCorrect(t *testing.T, terraformOptions *terraform.Options, numAzs int) {
	publicCidrBlocks := terraform.OutputList(t, terraformOptions, "public_subnet_cidr_blocks")
	assert.Equal(t, numAzs, len(publicCidrBlocks), "Expected %d Public CIDR Blocks, got %d", numAzs, (publicCidrBlocks))

	// Should have format 10.0.*.0/24
	for i, cidr := range publicCidrBlocks {
		assert.Equal(t, fmt.Sprintf("10.0.%d.0/24", i+1), cidr)
	}
}

func assertCidrBlocksAreCorrect(t *testing.T, terraformOptions *terraform.Options, numAzs int) {
	privateCidrBlocks := terraform.OutputList(t, terraformOptions, "private_subnet_cidr_blocks")
	assert.Equal(t, numAzs, len(privateCidrBlocks), "Expected %d Private CIDR Blocks, got %d", numAzs, (privateCidrBlocks))

	// Should have format 10.0.*.0/24 Picking up from the end of the private subnets
	for i, cidr := range privateCidrBlocks {
		assert.Equal(t, fmt.Sprintf("10.0.%d.0/24", numAzs+i+1), cidr)
	}
}

func assertVpcExists(t *testing.T, terraformOptions *terraform.Options, awsRegion string) string {
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	vpc := aws.GetVpcById(t, vpcID, awsRegion)
	assert.NotNil(t, vpc, "Expected VPC to exist")
	return vpcID
}

func assertVpcHasCorrectNumberOfSubnets(t *testing.T, terraformOptions *terraform.Options, awsRegion string, subnetId string, numAzs int) {
	subnets := terraform.OutputList(t, terraformOptions, subnetId)
	assert.Equal(t, numAzs, len(subnets), "Expected %d Subnets, got %d", numAzs, len(subnets))
}
