
# AMI Lookup
module "ami_lookup" {
  source = "../ami"
  os     = var.os
  arch   = var.arch
}

# DO NOT USE THESE (OBSOLETE)
# aws_launch_configuration
# vpc_security_group_ids

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "asg" {
  # name_prefix = "lt-${var.name}-"
  name                                 = "lt-${var.name}"
  disable_api_stop                     = !var.dev_mode
  disable_api_termination              = !var.dev_mode
  image_id                             = var.ami == "" ? module.ami_lookup.ami_id : var.ami
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  # key_name = not needed, use the web shell instead
  ebs_optimized = true

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

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    description                 = "asg-network"
    # Don't specify this here in the Launch Template, use the ASG
    # subnet_id                 = var.subnet_id
    security_groups = var.security_groups
  }

  # placement {
  #   availability_zone = "${data.aws_region.current.region}a"
  #   # group_name = aws_placement_group.main.name
  # }

  # tag_specifications {
  #   resource_type = "instance"
  #   tags = merge(var.tags, {
  #     Name = "lt-test"
  #   })
  # }

  # Encrypt root EBS volume
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted             = true
      kms_key_id            = var.kms_key_id
      delete_on_termination = true
      volume_type           = "gp3"
      volume_size           = var.root_volume_size
    }
  }

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
resource "aws_autoscaling_policy" "main" {
  name                      = "asg-policy-${var.name}"
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
  # name_prefix        = "asg-${var.name}-"
  name                 = "asg-${var.name}"
  min_size             = var.count_min
  max_size             = var.count_max
  termination_policies = ["OldestInstance"]

  # DO NOT USE
  # availability_zones      = ["${data.aws_region.current.region}a"]
  vpc_zone_identifier       = local.subnet_ids
  default_cooldown          = var.seconds_cooldown
  default_instance_warmup   = var.seconds_warmup
  health_check_type         = var.health_check_type
  health_check_grace_period = var.seconds_health
  force_delete              = var.dev_mode ? true : false
  protect_from_scale_in     = !var.dev_mode
  capacity_rebalance        = true

  # TODO: load_balancer attachment
  # placement_group         = aws_placement_group.main.id

  launch_template {
    id      = aws_launch_template.asg.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = "asg-${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "ForceRefreshTrigger"
    value               = var.force_refresh_trigger
    propagate_at_launch = true
  }

  # Instance refresh for safe rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.instance_refresh_min_healthy_percentage
      instance_warmup        = var.seconds_warmup
    }
    triggers = ["tag"]
  }

}

# SNS notifications for ASG events
resource "aws_autoscaling_notification" "asg_notifications" {
  group_names = [aws_autoscaling_group.asg.name]
  topic_arn   = var.sns_topic_arn

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
}

# TODO: Explore
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group
# resource "aws_placement_group" "test" {
#   name     = "test"
#   strategy = "cluster"
# }
