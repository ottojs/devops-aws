
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule_group
# resource "aws_scheduler_schedule_group" "example" {
#   name = "example"
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule
resource "aws_scheduler_schedule" "cron" {
  # name_prefix = ""
  name        = "cron-${var.name}"
  description = "Scheduled Task Container"
  group_name  = "default"

  kms_key_arn = var.kms_key.arn

  flexible_time_window {
    mode = "OFF"
  }

  # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  schedule_expression_timezone = var.timezone
  schedule_expression          = var.schedule

  target {
    arn      = var.ecs_cluster.arn
    role_arn = aws_iam_role.cron.arn

    ecs_parameters {
      launch_type         = var.type
      task_definition_arn = aws_ecs_task_definition.main.arn

      # TODO: Dynamic Security Group
      network_configuration {
        subnets          = local.subnet_ids
        security_groups  = [aws_security_group.main.id]
        assign_public_ip = false
      }
    }

    retry_policy {
      maximum_event_age_in_seconds = 120
      maximum_retry_attempts       = 5
    }
  }
}
