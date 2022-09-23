#################################
# ecs
# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest
#################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.1"

  default_capacity_provider_use_fargate = false

  cluster_name = "${var.project_name}-cluster"

  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn = var.autoscaling_group_arn
    }
  }
}