
# # Kafka v4.x (using KRaft only)
# # Takes about 33 minutes to create
# # Takes about 7  minutes to delete
# module "kafka" {
#   source              = "../../modules/kafka_msk"
#   name                = "my-kafka"
#   vpc                 = module.myvpc.vpc
#   subnet_ids          = module.myvpc.subnets_private_ids
#   log_bucket_id       = data.aws_s3_bucket.logging.id
#   log_retention_days  = var.log_retention_days
#   sns_topic_arn       = module.sns.topic_arn
#   sasl_scram_users    = ["myapp"]
#   allowed_cidr_blocks = [module.myvpc.vpc.cidr_block]
#   # machine_type      = "m5.large"
#   # disk_size_initial = 10 # (in GB)
#   tags     = var.tags
#   dev_mode = true
# }

# Topic Configuration - Topics must be created using Kafka clients after cluster deployment
# Example using kafka-topics.sh:
# kafka-topics.sh --bootstrap-server <broker-endpoint> --create --topic my-topic --partitions 12 --replication-factor 3
#
# Trust relationships for IAM roles:
# - Producer/Consumer roles: Trust EC2, ECS by default
# - Admin role: Root account only with MFA required (may be disabled in the future)
#
# IAM group prefixes - Smart defaults:
# Admin has access to all groups
# Producer groups: "producer-*"
# Consumer groups: "consumer-*"
# 
# Topic-specific policies are not used
# Use producer/consumer roles with topic prefix patterns instead
