
# Fargate Platform Versions
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform-fargate.html
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "main" {
  # TODO: Review
  lifecycle {
    create_before_destroy = true
  }
  name            = var.name
  cluster         = var.ecs_cluster.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  ###
  # TODO: Variable for Switching
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  # launch_type    = "EC2"
  ###

  # TODO: Review
  force_new_deployment = false
  #   iam_role        = aws_iam_role.main.arn
  # TODO: Prevent Race Condition
  # depends_on      = [aws_iam_role_policy.main]
  wait_for_steady_state = false

  # Only in EC2
  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  network_configuration {
    subnets          = local.subnet_ids
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.id
    # This needs to match the container definition names above
    container_name = var.name
    container_port = 8080
  }

  # depends_on = [
  #   aws_lb_listener.http_forward,
  #   aws_iam_role_policy_attachment.ecs_task_execution_role
  # ]

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }

  tags = {
    key   = "App"
    value = var.tag_app
  }
}
