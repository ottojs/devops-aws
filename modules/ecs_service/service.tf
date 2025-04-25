
# Fargate Platform Versions
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform-fargate.html
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "main" {
  count = var.mode != "cron" && var.skeleton == false ? 1 : 0
  # TODO: Review
  lifecycle {
    create_before_destroy = true
  }
  name             = var.name
  cluster          = data.aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.main.arn
  desired_count    = var.replicas
  launch_type      = var.type
  platform_version = var.type == "FARGATE" ? "1.4.0" : null

  # TODO: Review
  force_new_deployment = false
  # iam_role        = aws_iam_role.main.arn
  # TODO: Prevent Race Condition
  # depends_on      = [aws_iam_role_policy.main]
  wait_for_steady_state = false

  # TODO: Only in EC2
  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  # TODO: Dynamic Security Group
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  }

  # Only if mode is server
  dynamic "load_balancer" {
    for_each = var.mode == "server" ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.main[0].id
      # This needs to match the container definition names above
      container_name = var.name
      container_port = 8080
    }
  }

  # depends_on = [
  #   aws_iam_role_policy_attachment.ecs_task_execution_role
  # ]

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }

  tags = var.tags
}
