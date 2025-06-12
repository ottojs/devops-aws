
# Secrets Manager access for SASL/SCRAM authentication
resource "aws_iam_policy" "msk_secrets_access" {
  count = length(var.sasl_scram_users) > 0 ? 1 : 0

  name        = "${var.name}-msk-secrets-access"
  path        = "/"
  description = "Access to MSK SASL/SCRAM secrets for ${var.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          for secret in aws_secretsmanager_secret.msk_credentials : secret.arn
        ]
      },
      {
        Sid    = "KMSDecryptAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.msk.arn
        Condition = {
          StringEquals = {
            "kms:ViaService"                  = "secretsmanager.${data.aws_region.current.region}.amazonaws.com"
            "kms:EncryptionContext:SecretARN" = "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:AmazonMSK_${var.name}_*"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-msk-secrets-access"
  })
}

# Attach secrets access to producer and consumer roles
resource "aws_iam_role_policy_attachment" "msk_producer_secrets" {
  count = length(var.sasl_scram_users) > 0 ? 1 : 0

  role       = aws_iam_role.msk_producer.name
  policy_arn = aws_iam_policy.msk_secrets_access[0].arn
}

resource "aws_iam_role_policy_attachment" "msk_consumer_secrets" {
  count = length(var.sasl_scram_users) > 0 ? 1 : 0

  role       = aws_iam_role.msk_consumer.name
  policy_arn = aws_iam_policy.msk_secrets_access[0].arn
}

resource "aws_iam_role_policy_attachment" "msk_admin_secrets" {
  count = length(var.sasl_scram_users) > 0 ? 1 : 0

  role       = aws_iam_role.msk_admin.name
  policy_arn = aws_iam_policy.msk_secrets_access[0].arn
}
