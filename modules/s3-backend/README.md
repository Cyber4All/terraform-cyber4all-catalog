# S3 Backend

This folder contains a [Terraform](https://www.terraform.io/) module that defines an S3 bucket and DynamoDB table that can be used as a remote backend for terraform state files.

## Quick Start

In a terraform file below the terraform block use a module block to add the s3-backend module.

```hcl
terraform {
    required_version = "1.2.9"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 4.0.0"
        }
    }
}

module "s3-backend" {
    source = "https://github.com/Cyber4All/terraform-module.git//modules/s3-backend"

    bucket_name = "example-bucket"
    dynamodb_table_name = "example-lock-table"

    # ... (other params omitted) ...
}
```

Initialize terraform in the directory

```console
terraform init
```

This will use a local backend at first

Provision the bucket with apply (assuming plan already verified)

```console
terraform apply -auto-approve
```

The S3 bucket and DynamoDB table should be provisioned

Change the backend type to use S3 remote

```hcl
terraform {
  # ... (other params omitted) ...

  backend "s3" {
    bucket = "example-bucket"
    key    = "live/example/s3-backend/terraform.tfstate" # key should follow project structure
    region = "us-east-1" # us-east-1 was used as the default region in the s3-backend module

    dynamodb_table = "example-lock-table"
    encrypt        = true
  }
}
```

Re-initialize the project to use the remote backend

```console
terraform init -migrate-state
```

The S3-backend is all setup and can be used how the `backend "s3" { ... }` was used.

*Note that the `key` in the `backend "s3" { ... }` block should be unique for every distinct .tfstate file
