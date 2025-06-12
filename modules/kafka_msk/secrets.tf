# AWS Secrets Manager for SASL/SCRAM credentials

# Generate secure passwords for SASL/SCRAM users
resource "random_password" "msk_user_passwords" {
  for_each = toset(var.sasl_scram_users)

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 4
  min_upper        = 4
  min_numeric      = 4
  min_special      = 4
}

resource "aws_secretsmanager_secret" "msk_credentials" {
  for_each = toset(var.sasl_scram_users)

  name                    = "msk/${var.name}/${each.value}"
  description             = "MSK SASL/SCRAM credentials for ${each.value}"
  recovery_window_in_days = 30
  kms_key_id              = aws_kms_key.msk.arn

  tags = merge(var.tags, {
    Name = "${var.name}-${each.value}"
  })
}

resource "aws_secretsmanager_secret_version" "msk_credentials" {
  for_each = toset(var.sasl_scram_users)

  secret_id = aws_secretsmanager_secret.msk_credentials[each.value].id
  secret_string = jsonencode({
    username = each.value
    password = random_password.msk_user_passwords[each.value].result
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Associate secrets with MSK cluster
resource "aws_msk_scram_secret_association" "main" {
  count       = length(var.sasl_scram_users) > 0 ? 1 : 0
  cluster_arn = aws_msk_cluster.main.arn
  secret_arn_list = [
    for secret in aws_secretsmanager_secret.msk_credentials : secret.arn
  ]

  depends_on = [aws_secretsmanager_secret_version.msk_credentials]
}
