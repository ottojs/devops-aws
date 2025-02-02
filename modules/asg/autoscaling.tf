
# DO NOT USE THESE (OBSOLETE)
# aws_launch_configuration
# vpc_security_group_ids

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "asg" {
  # name_prefix = "lt-${var.name}-"
  name                                 = "tf-lt-${var.name}"
  disable_api_stop                     = false
  disable_api_termination              = false
  image_id                             = var.ami
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  vpc_security_group_ids               = var.security_groups
  # key_name = not needed, use the web shell instead

  iam_instance_profile {
    name = var.iam_instance_profile.name
  }

  # IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  monitoring {
    enabled = true
  }

  # network_interfaces {
  #   associate_public_ip_address = true
  #   delete_on_termination       = true
  #   description                 = "asg-network"
  #   # subnet_id                 = var.subnet_id
  #   security_groups             = var.security_groups
  # }

  # placement {
  #   availability_zone = "us-east-2a"
  #   # group_name = aws_placement_group.main.name
  # }

  # tag_specifications {
  #   resource_type = "instance"
  #   tags = {
  #     Name = "lt-test"
  #     App  = var.tag_app
  #   }
  # }

  # Options for Referencing Userdata
  # file, filebase64, base64encode, templatefile
  # user_data = filebase64("${path.module}/userdata.sh")
  user_data = base64encode(var.userdata_file)

  # This setting conflicts with instance_type
  # instance_requirements {
  #   allowed_instance_types = [var.instance_type]
  #   bare_metal             = "excluded"
  #   vcpu_count {
  #     min = 1
  #   }
  #   memory_mib {
  #     min = 512
  #   }
  # }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy
resource "aws_autoscaling_policy" "example" {
  name                      = "tf-asg-policy-${var.name}"
  autoscaling_group_name    = aws_autoscaling_group.asg.name
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = var.seconds_warmup
  enabled                   = true
  target_tracking_configuration {
    target_value     = var.scale_up_cpu
    disable_scale_in = false
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

# We do not supply this argument because it can affect autoscaling
# desired_capacity = var.count_desired
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "asg" {
  # name_prefix        = "tf-asg-${var.name}-"
  name                 = "tf-asg-${var.name}"
  min_size             = var.count_min
  max_size             = var.count_max
  termination_policies = ["OldestInstance"]

  # DO NOT USE
  # availability_zones      = ["us-east-2a"]
  vpc_zone_identifier       = local.subnet_ids
  default_cooldown          = var.seconds_cooldown
  default_instance_warmup   = var.seconds_warmup
  health_check_grace_period = var.seconds_health
  force_delete              = true
  protect_from_scale_in     = false

  # TODO: load_balancer attachment
  # placement_group         = aws_placement_group.main.id

  launch_template {
    id      = aws_launch_template.asg.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "App"
    value               = var.tag_app
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

# TODO: Explore
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group
# resource "aws_placement_group" "test" {
#   name     = "test"
#   strategy = "cluster"
# }
