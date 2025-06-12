data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Log groups and tagging
locals {
  main_log_group_name = "devops/ecs/cluster/${var.name}/main"
  exec_log_group_name = "devops/ecs/cluster/${var.name}/exec"
}

# Note: Encryption at rest for ECS clusters is handled differently based on launch type:
# - FARGATE: AWS manages encryption automatically
# - EC2: Configure encryption in the launch template of the Auto Scaling Group
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
resource "aws_ecs_cluster" "main" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = var.kms_key.id
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = local.exec_log_group_name
      }
    }
  }
  tags = merge(var.tags, {
    Name = "ecs-cluster-${var.name}"
  })
}

# CloudWatch log group for ECS Exec audit logs
resource "aws_cloudwatch_log_group" "exec_logs" {
  name              = local.exec_log_group_name
  kms_key_id        = var.kms_key.arn
  skip_destroy      = !var.dev_mode
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "main" {
  name              = local.main_log_group_name
  kms_key_id        = var.kms_key.arn
  skip_destroy      = !var.dev_mode
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

###################
##### Fargate #####
###################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers
resource "aws_ecs_cluster_capacity_providers" "fargate" {
  count              = var.type == "FARGATE" ? 1 : 0
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

###############################
##### EC2 ASG Self-Hosted #####
###############################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers
resource "aws_ecs_cluster_capacity_providers" "ec2" {
  count        = var.type == "EC2" ? 1 : 0
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.ec2[0].name]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ec2[0].name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider
resource "aws_ecs_capacity_provider" "ec2" {
  count = var.type == "EC2" ? 1 : 0
  name  = var.asg.name

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.asg.arn
    # Requires "protection from scale-in" to be enabled on the ASG/LT
    managed_termination_protection = var.asg.protect_from_scale_in ? "ENABLED" : "DISABLED"
    managed_draining               = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }
}
