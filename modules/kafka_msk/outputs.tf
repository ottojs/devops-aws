
output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value       = aws_msk_cluster.main.arn
}

output "bootstrap_brokers" {
  description = "Bootstrap broker endpoints for different authentication methods"
  value = {
    tls        = aws_msk_cluster.main.bootstrap_brokers_tls
    iam        = aws_msk_cluster.main.bootstrap_brokers_sasl_iam
    sasl_scram = aws_msk_cluster.main.bootstrap_brokers_sasl_scram
  }
}

output "security_group_id" {
  description = "Security group ID for MSK cluster access"
  value       = aws_security_group.msk_sg.id
}

output "iam_roles" {
  description = "IAM roles for MSK access (producer, consumer, admin)"
  value = {
    producer = {
      arn              = aws_iam_role.msk_producer.arn
      instance_profile = aws_iam_instance_profile.msk_producer.arn
    }
    consumer = {
      arn              = aws_iam_role.msk_consumer.arn
      instance_profile = aws_iam_instance_profile.msk_consumer.arn
    }
    admin = {
      arn = aws_iam_role.msk_admin.arn
    }
  }
}

output "sasl_scram_secrets" {
  description = "Secrets Manager ARNs for SASL/SCRAM users (if configured)"
  value = {
    for username in var.sasl_scram_users : username => aws_secretsmanager_secret.msk_credentials[username].arn
  }
  sensitive = true
}

output "kms_key_arn" {
  description = "KMS key ARN used for MSK encryption (cluster, logs, and secrets)"
  value       = aws_kms_key.msk.arn
}

output "kms_key_alias" {
  description = "KMS key alias for MSK encryption"
  value       = aws_kms_alias.msk.name
}
