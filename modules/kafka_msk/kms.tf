# KMS Key for encryption at rest with encryption context enforcement
# This key requires encryption context for all operations to enhance security
# The encryption context ensures that KMS operations are tied to specific resources
resource "aws_kms_key" "msk" {
  description             = "MSK encryption key for ${var.name}"
  deletion_window_in_days = 30   # Maximum protection
  enable_key_rotation     = true # Security best practice

  # Add encryption context policy for enhanced security
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow MSK to use the key with encryption context"
        Effect = "Allow"
        Principal = {
          Service = "kafka.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:kafka:cluster-arn" = "arn:aws:kafka:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.name}/*"
          }
        }
      },
      {
        Sid    = "Allow CloudWatch Logs to use the key with encryption context"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:devops/msk/${var.name}"
          }
        }
      },
      {
        Sid    = "Allow Secrets Manager to use the key with encryption context"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService"                  = "secretsmanager.${data.aws_region.current.region}.amazonaws.com"
            "kms:EncryptionContext:SecretARN" = "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:AmazonMSK_${var.name}_*"
          }
        }
      },
      {
        Sid    = "Allow S3 to use the key for MSK log encryption"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.${data.aws_region.current.region}.amazonaws.com"
          }
          StringLike = {
            "kms:EncryptionContext:aws:s3:arn" = "arn:aws:s3:::*/devops/msk/${var.name}/*"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_kms_alias" "msk" {
  name          = "alias/msk-${var.name}"
  target_key_id = aws_kms_key.msk.key_id
}
