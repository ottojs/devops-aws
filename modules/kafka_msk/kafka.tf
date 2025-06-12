
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster
resource "aws_msk_cluster" "main" {
  cluster_name           = var.name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = length(var.subnet_ids)

  broker_node_group_info {
    instance_type = "kafka.${var.machine_type}"
    # MSK automatically implements rack awareness by distributing brokers across AZs
    # Each subnet should be in a different AZ for proper fault tolerance
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.msk_sg.id]
    storage_info {
      ebs_storage_info {
        volume_size = var.dev_mode ? 10 : var.disk_size_initial # GB per broker
        # kafka.m5.4xlarge or larger required
        # provisioned_throughput {
        #   enabled = true
        #   volume_throughput = 250 # or more
        # } 
      }
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.msk.arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  # SASL/SCRAM and IAM ONLY. No TLS, No Unauthentciated
  # Only enable SCRAM if users are provided
  # Always enable IAM for AWS-native authentication
  client_authentication {
    sasl {
      scram = length(var.sasl_scram_users) > 0
      iam   = true
    }
    unauthenticated = false
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = var.dev_mode ? false : true
        log_group = var.dev_mode ? null : aws_cloudwatch_log_group.msk[0].name
      }
      s3 {
        enabled = true
        bucket  = var.log_bucket_id
        prefix  = "devops/msk/${var.name}"
      }
    }
  }

  # TODO: Review
  # open_monitoring {
  #   prometheus {
  #     jmx_exporter {
  #       enabled_in_broker = var.dev_mode ? false : true
  #     }
  #     node_exporter {
  #       enabled_in_broker = var.dev_mode ? false : true
  #     }
  #   }
  # }

  # Enhanced monitoring - smart defaults based on dev_mode
  enhanced_monitoring = var.dev_mode ? "DEFAULT" : "PER_BROKER"

  # Configuration - Always use our custom configuration for consistency
  configuration_info {
    arn      = aws_msk_configuration.custom.arn
    revision = aws_msk_configuration.custom.latest_revision
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

# MSK Configuration
resource "aws_msk_configuration" "custom" {
  name           = "${var.name}-config"
  description    = "Custom configuration for ${var.name} MSK cluster"
  kafka_versions = [var.kafka_version]

  server_properties = join("\n", [
    "default.replication.factor=${local.computed_replication_factor}",
    "min.insync.replicas=${local.computed_min_isr}",
    "unclean.leader.election.enable=false",                   # Always false to prevent data loss
    "log.retention.hours=${var.dev_mode ? 72 : 168}",         # 3 days for dev, 7 days for production
    "log.retention.bytes=${var.dev_mode ? 10737418240 : -1}", # 10GB for dev, unlimited for production
    "auto.create.topics.enable=false",                        # Explicit topic creation is safer
    "compression.type=${var.compression_type}",
    "message.max.bytes=1048588",       # Default 1MB
    "replica.fetch.max.bytes=1048576", # Default 1MB
    "delete.topic.enable=true",
    "log.cleanup.policy=delete"
  ])
}
