# Secrets Manager

## Overview

This module contains Terraform code to deploy multiple [AWS SecretsManager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) secrets with key/value pairs defined. This module is mainly used to setup secrets manager and create the secret ARN references to be consumed by other modules.

<!-- Image or Arch diagram -->

## Learn

<!-- A few references to Secrets Manager (documentation, blog, etc...) -->

SecretsManager is a service that allows for the storage of sensitive secrets that are encrypted. This use case the module was developed for was for defining secrets that are used in applications. The applications that reference these values are retrieve the secrets as environment variable secrest in ECS or through the application code directly.

For more information about [using SecretsManager in ECS container definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar-secrets-manager.html) read the considerations and implementation guide.

For more information about [retrieving secrets with the AWS API](https://docs.aws.amazon.com/secretsmanager/latest/userguide/retrieving-secrets.html) check out the guide for the language the application is developed in.

When defining the secret name and value, do not hard code sensitive values in the code! These values should injected on `apply`.
