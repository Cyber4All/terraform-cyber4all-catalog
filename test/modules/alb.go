package modules

import (
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/elbv2"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func DeployAlb(t *testing.T, workingDir string) {
	// Generate a unique ID
	uniqueId := strings.ToLower(random.UniqueId())

	// Get a random AWS region
	awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "us-east-2"}, nil)
	test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"random_id": uniqueId,
			"region":    awsRegion,
		},
	})

	// Save the options so later test stages can use them
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
}

func ValidateAlbNoHttps(t *testing.T, workingDir string) {
	// Connect to aws using aws sdk
	session, err := session.NewSession()
	if err != nil {
		t.Fatal(err)
	}

	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	// Get the random id
	expectedAlbName := terraform.Output(t, terraformOptions, "alb_name")

	elb := elbv2.New(session, &aws_sdk.Config{Region: aws_sdk.String(awsRegion)})

	// Check that the alb exists
	lb := assertAlbExists(t, elb, awsRegion, expectedAlbName)

	// Check that the alb returns a 404 when we try to access it
	dnsName := terraform.Output(t, terraformOptions, "alb_dns_name")
	assertAlbReturns404(t, fmt.Sprintf("http://%s:80", dnsName))

	// Check the outputs of the alb
	assertAlbOutputs(t, terraformOptions, lb, false)
}

func ValidateAlbHttps(t *testing.T, workingDir string) {
	// Connect to aws using aws sdk
	session, err := session.NewSession()
	if err != nil {
		t.Fatal(err)
	}

	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	expectedAlbName := terraform.Output(t, terraformOptions, "alb_name")

	elb := elbv2.New(session, &aws_sdk.Config{Region: aws_sdk.String(awsRegion)})

	// Check that the alb exists
	lb := assertAlbExists(t, elb, awsRegion, expectedAlbName)

	// Check that the alb returns a 404 when we try to access it
	dnsRecName := terraform.Output(t, terraformOptions, "alb_dns_record_name")
	assertAlbReturns404(t, fmt.Sprintf("https://%s:443", dnsRecName))

	// Check the outputs of the alb
	assertAlbOutputs(t, terraformOptions, lb, true)
}

func assertAlbOutputs(t *testing.T, terraformOptions *terraform.Options, lb *elbv2.LoadBalancer, isHttps bool) {
	// Check that the alb arn is the same as the output
	albArn := terraform.Output(t, terraformOptions, "alb_arn")
	assert.Equal(t, albArn, *lb.LoadBalancerArn, "Expected alb arn to be %s, got %s", albArn, *lb.LoadBalancerArn)

	// Check alb dns name
	dnsName := terraform.Output(t, terraformOptions, "alb_dns_name")
	assert.Equal(t, dnsName, *lb.DNSName, "Expected alb dns name to be %s, got %s", dnsName, *lb.DNSName)

	// Check the alb name
	albName := terraform.Output(t, terraformOptions, "alb_name")
	assert.Equal(t, albName, *lb.LoadBalancerName, "Expected alb name to be %s, got %s", albName, *lb.LoadBalancerName)

	// Check the alb security group id
	assert.True(t, lb.SecurityGroups != nil, "Expected alb security group id to not be nil")
	assert.True(t, len(lb.SecurityGroups) == 1, "Expected alb security group id to have 1 security group")
	assert.Equal(t, terraform.Output(t, terraformOptions, "alb_security_group_id"), *lb.SecurityGroups[0], "Expected alb security group id to be %s, got %s", terraform.Output(t, terraformOptions, "alb_security_group_id"), *lb.SecurityGroups[0])

	if isHttps {
		// Check alb zone id
		zoneId := terraform.Output(t, terraformOptions, "alb_hosted_zone_id")
		assert.Equal(t, zoneId, *lb.CanonicalHostedZoneId, "Expected alb zone id to be %s, got %s", zoneId, *lb.CanonicalHostedZoneId)

		// Check the dns record name
		dnsRecordName := terraform.Output(t, terraformOptions, "alb_dns_record_name")
		assert.Equal(t, dnsRecordName, "api.lieutenant-dan.click", "Expected alb dns record name to be %s, got %s", "api.lieutenant-dan.click", dnsRecordName)
	}
}

func assertAlbReturns404(t *testing.T, route string) {
	// Wait a minute for the alb to be ready
	time.Sleep(1 * time.Minute)
	// Hit the alb
	res, err := http.Get(route)
	if err != nil {
		t.Fatal(err)
	}

	// Check that the status code is 404
	if res.StatusCode != 404 {
		t.Fatalf("Expected status code 404, got %d", res.StatusCode)
	}

	// Check that the message body is "404 not found"
	if res.Body == nil {
		t.Fatal("Expected body to not be nil")
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		t.Fatal(err)
	}
	if string(body[:]) != "404 Not Found" {
		t.Fatalf("Expected body to be '404 Not Found', got %s", string(body[:]))
	}
}

func assertAlbExists(t *testing.T, elb *elbv2.ELBV2, awsRegion string, expectedAlbName string) *elbv2.LoadBalancer {
	output, err := elb.DescribeLoadBalancers(&elbv2.DescribeLoadBalancersInput{
		Names: []*string{
			aws_sdk.String(expectedAlbName),
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	t.Log(output)

	if len(output.LoadBalancers) != 1 {
		t.Fatalf("Expected 1 alb, got %d", len(output.LoadBalancers))
	}

	return output.LoadBalancers[0]
}
