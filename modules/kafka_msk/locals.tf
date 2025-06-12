# Local values for tag management and other computed values
locals {

  # Compute replication factor based on broker count
  computed_replication_factor = min(3, length(var.subnet_ids))

  # Compute min ISR based on replication factor (always replication_factor - 1, minimum 1)
  computed_min_isr = max(1, local.computed_replication_factor - 1)

  # Default trusted services for roles
  default_trusted_services = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]

  # Encryption contexts for enhanced security
  msk_encryption_context = {
    "aws:kafka:cluster-name" = var.name
    "aws:kafka:cluster-arn"  = "arn:aws:kafka:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.name}"
  }

  cloudwatch_encryption_context = {
    "aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:devops/msk/${var.name}"
  }

  # Partition recommendations based on broker count
  broker_count = length(var.subnet_ids)

  partition_guidance = {
    small_topic  = max(3, local.broker_count)      # Low throughput topics
    medium_topic = max(12, local.broker_count * 3) # Medium throughput topics  
    large_topic  = max(24, local.broker_count * 6) # High throughput topics
  }
}
