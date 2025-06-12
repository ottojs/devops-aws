
# KMS key for SSM module
resource "aws_kms_alias" "ssm" {
  name          = "alias/ssm-${data.aws_region.current.region}"
  target_key_id = aws_kms_key.ssm.key_id
}

resource "aws_kms_key" "ssm" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "KMS key for SSM session manager and logs"
  enable_key_rotation      = true
  rotation_period_in_days  = 90
  multi_region             = false
  deletion_window_in_days  = 7
  tags                     = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "kms-ssm"
    Statement = [
      {
        Sid    = "Allow administration by root user"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      # Allow CloudWatch Logs to use the key
      {
        Sid    = "Allow use of the key by CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.region}.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = [
              "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:devops/aws/ssm/sessions",
              "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:devops/aws/cloudtrail/ssm"
            ]
          }
        }
      },
      # Additional CloudWatch Logs permissions without conditions
      {
        Sid    = "Enable CloudWatch Logs encryption"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.region}.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      # Allow SSM service to use the key
      {
        Sid    = "Allow SSM to use the key"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = "*"
      },
      # Allow EC2 SSM role to use the key
      {
        Sid    = "Allow use of the key by EC2 for SSM"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2-ssm"
        },
        Action = [
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:CreateGrant"
        ],
        Resource = "*"
      },
      # Allow S3 to use the key for SSM session logs
      {
        Sid    = "Allow S3 to use the key for SSM logs"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.${data.aws_region.current.region}.amazonaws.com"
          }
        }
      },
      # Allow CloudTrail to use the key
      {
        Sid    = "Allow CloudTrail to use the key"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = [
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      }
    ]
  })
}