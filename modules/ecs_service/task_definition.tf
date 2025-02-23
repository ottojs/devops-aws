
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "main" {
  family       = var.name
  network_mode = "awsvpc" # none, bridge, awsvpc, host
  # TODO: Split These
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  requires_compatibilities = [var.type]
  cpu                      = var.cpu
  memory                   = var.ram
  # ephemeral_storage {
  #   # 21GiB => 200GiB
  #   size_in_gib = 21
  # }

  container_definitions = jsonencode([
    {
      name                   = var.name
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.name}:${var.tag}"
      cpu                    = var.cpu
      memory                 = var.ram
      essential              = true
      enable_fault_injection = var.fault_injection
      # Environment Variables are (almost) always passed as strings
      environment = [for k, v in merge(var.envvars, {
        PORT = "8080"
        }) :
        {
          name  = k
          value = v
        }
      ]
      portMappings = [
        {
          name = "http"
          # Both ports are required to be the same
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http2"
        }
      ]
      ulimits = [
        {
          name : "nofile"
          softLimit : 65535
          hardLimit : 65535
        }
      ]
      # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar-secrets-manager.html
      # https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_iam-policies.html
      secrets = [for k, v in var.secrets :
        {
          name      = k
          valueFrom = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:apps/${var.name}/${v}"
        }
      ]
      # requiresAttributes = [
      #   "EC2"
      #   # {
      #   #   name = "com.amazonaws.ecs.capability.logging-driver.awslogs"
      #   # },
      #   # {
      #   #   name = "ecs.capability.execution-role-awslogs"
      #   # }
      # ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = "devops/aws/ecs/${var.ecs_cluster.name}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "service"
          "mode"                  = "non-blocking"
          "max-buffer-size"       = "1m"
        }
      }
    }
    # ... you can add others / sidecars
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.arch # X86_64 or ARM64
  }

  #   volume {
  #     name      = "service-storage"
  #     host_path = "/ecs/service-storage"
  #   }

  #   placement_constraints {
  #     type       = "memberOf"
  #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #   }

  tags = var.tags
}
