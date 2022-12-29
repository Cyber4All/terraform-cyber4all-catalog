terraform {
  required_version = "1.2.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }

  backend "s3" {
    bucket = "terraform-module-terraform-states"
    key    = "live/example/lambda-example/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-mdoule-terraform-locks"
    encrypt        = true
  }
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "4.7.1"

  function_name = "example-function"
  description   = "An example of provisioning a lambda function"

  runtime                  = "python3.9"
  handler                  = "app.lambda_handler"
  compatible_architectures = ["x86_64"]

  create_package         = false
  local_existing_package = "${path.cwd}/deployment-package.zip"
  package_type           = "Zip"
  publish                = true

  memory_size                = 128
  timeout                    = 60
  create_lambda_function_url = true
  maximum_retry_attempts     = 0
  recreate_missing_package   = false

  environment_variables = {
    "JWT_SECRET"      = "secret", # once source code gets from Secretsmanager this should be secret ARNS
    "SERVICE_SECRET"  = "secret",
    "CLARK_MONGO_URI" = "mongodb://mongodb:27017",
    "CC_MONGO_URI"    = "mongodb://mongodb:27017"
    "PDP_URI"         = "http://localhost:3001"
  }

  attach_policies    = true
  number_of_policies = 1
  policies           = ["arn:aws:iam::317620868823:policy/SecretsManagerGetSecrets"]

  cloudwatch_logs_retention_in_days = 365

  /* allowed_triggers = {} */
  /* architectures = ["x86_64"] */
  /* artifacts_dir = "builds" */
  /* assume_role_policy_statements = {} */
  /* attach_async_event_policy = false */
  /* attach_cloudwatch_logs_policy = true */
  /* attach_dead_letter_policy = false */
  /* attach_network_policy = false */
  /* attach_policy = false */
  /* attach_policy_json = false */
  /* attach_policy_jsons = false */
  /* attach_policy_statements = false */
  /* attach_tracing_policy = false */
  /* authorization_type = "NONE" */
  /* build_in_docker = false */
  /* cloudwatch_logs_kms_key_id = null */
  /* code_signing_config_arn = null */
  /* compatible_runtimes = [] */
  /* cors = {} */
  /* create = true */
  /* create_async_event_config = false */
  /* create_current_version_allowed_triggers = true */
  /* create_current_version_async_event_config = true */
  /* create_function = true */
  /* create_layer = false */
  /* create_role = true */
  /* create_unqualified_alias_allowed_triggers = true */
  /* create_unqualified_alias_lambda_function_url = true */
  /* dead_letter_target_arn = null */
  /* destination_on_failure = null */
  /* destination_on_success = null */
  /* docker_additional_options = [] */
  /* docker_build_root = "" */
  /* docker_entrypoint = null */
  /* docker_file = "" */
  /* docker_image = "" */
  /* docker_pip_cache = null */
  /* docker_with_ssh_agent = false */
  /* ephemeral_storage_size = 512 */
  /* event_source_mapping = {} */
  /* file_system_arn = null */
  /* file_system_local_mount_path = null */
  /* hash_extra = "" */
  /* ignore_source_code_hash = false */
  /* image_config_command = [] */
  /* image_config_working_directory = null */
  /* image_uri = null */
  /* kms_key_arn = null */
  /* lambda_at_edge = false */
  /* lambda_role = "" */
  /* layer_name = "" */
  /* layer_skip_destroy = false */
  /* layers = null */
  /* license_info = "" */
  /* maximum_event_age_in_seconds = null */
  /* number_of_policy_jsons = 0 */
  /* policy = null */
  /* policy_json = null */
  /* policy_jsons = [] */
  /* policy_name = null */
  /* policy_path = null */
  /* policy_statements = {} */
  /* provisioned_concurrent_executions = -1 */
  /* putin_khuylo = true */
  /* reserved_concurrent_executions = -1 */
  /* role_description = null */
  /* role_force_detach_policies = true */
  /* role_name = null */
  /* role_path = null */
  /* role_permissions_boundary = null */
  /* role_tags = {} */
  /* s3_acl = null */
  /* s3_existing_package = null */
  /* s3_object_tags = {} */
  /* s3_object_tags_only = false */
  /* s3_prefix = null */
  /* s3_server_side_encryption = null */
  /* source_path = null */
  /* store_on_s3 = false */
  /* tags = {} */
  /* tracing_mode = null */
  /* trusted_entities = [] */
  /* use_existing_cloudwatch_log_group = false */
  /* vpc_subnet_ids = null */
}