# Always enable autoscaling to prevent disk full issues

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target
resource "aws_appautoscaling_target" "disk" {
  # For MSK storage autoscaling, min_capacity must be 1 and max_capacity is the scaling factor
  # The actual storage limits are set in the MSK cluster configuration
  # Actual max disk size = initial disk size × max_capacity
  # Example: 10GB initial * 16 max_capacity = 160GB max per broker
  # Note: After storage scales out, you can't decrease it
  max_capacity       = min(16, floor(var.disk_size_max / var.disk_size_initial)) # Calculate scaling factor (max 16)
  min_capacity       = 1                                                         # Must always be 1 for MSK storage autoscaling
  resource_id        = aws_msk_cluster.main.arn
  scalable_dimension = "kafka:broker-storage:VolumeSize"
  service_namespace  = "kafka"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy
resource "aws_appautoscaling_policy" "kafka_broker_scaling_policy" {
  name               = "${var.name}-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_msk_cluster.main.arn
  scalable_dimension = aws_appautoscaling_target.disk.scalable_dimension
  service_namespace  = aws_appautoscaling_target.disk.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "KafkaBrokerStorageUtilization"
    }
    target_value = 80
  }
}
