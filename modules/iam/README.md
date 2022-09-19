# IAM Module Examples

## Description

The IAM terraform module will be responsible for the provisioning of IAM roles for AWS Services, SDKs, and CICD services.

The IAM module includes many more submodules that can be used for other purposes.

## Usage: Create IAM Role with Custom Policy

1. Create custom policy
2. Create role that assumes policy

## Determining Minimum Actions Nessecary

To determine the actions required. Observe the logs for terraform apply.

```console
TF_LOG=trace terraform -chdir=modules/iam apply --auto-approve &> log.log

cat log.log | grep "DEBUG: Request"
```

The first command logs all the actions in the apply, while the second command will echo the aws actions called durring runtime.

## Using Roles in CICD

Posted On: [Jul 6, 2022](https://aws.amazon.com/about-aws/whats-new/2022/07/aws-identity-access-management-iam-roles-anywhere-workloads-outside-aws/) 

AWS Identity and Access Management (IAM) now enables workloads that run outside of AWS to access AWS resources using IAM Roles Anywhere. IAM Roles Anywhere allows your workloads such as servers, containers, and applications to use X.509 digital certificates to obtain temporary AWS credentials and use the same IAM roles and policies that you have configured for your AWS workloads to access AWS resources.

With IAM Roles Anywhere you now have the ability to use temporary credentials on AWS, eliminating the need to manage long term credentials for workloads running outside of AWS, which can help improve your security posture. Using IAM Roles Anywhere can reduce support costs and operational complexity through using the same access controls, deployment pipelines, and testing processes across all of your workloads. You can get started by establishing the trust between your AWS environment and your public key infrastructure (PKI). You do this by creating a trust anchor where you either reference your AWS Certificate Manager Private Certificate Authority (ACM Private CA) or register your own certificate authorities (CAs) with IAM Roles Anywhere. By adding one or more roles to a profile and enabling IAM Roles Anywhere to assume these roles, your applications can now use the client certificate issued by your CAs to make secure requests to AWS and get temporary credentials to access the AWS environment.

IAM Roles Anywhere is available in most commercial regions at no additional cost. Please see the documentation for more information on supported regions.

[IAM Roles Anywhere](https://docs.aws.amazon.com/rolesanywhere/latest/userguide/introduction.html)
[Creating a Private CA and Trust Anchor](https://docs.aws.amazon.com/rolesanywhere/latest/userguide/getting-started.html)
