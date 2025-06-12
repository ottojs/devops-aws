
# Admin Role - Full access to cluster
resource "aws_iam_role" "msk_admin" {
  name = "${var.name}-msk-admin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          Bool = {
            # TODO: May need to be disabled
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-msk-admin"
  })
}

# Admin Policy
resource "aws_iam_policy" "msk_admin" {
  name        = "${var.name}-msk-admin"
  path        = "/"
  description = "MSK admin policy for ${var.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "MSKFullAccess"
        Effect = "Allow"
        Action = [
          "kafka-cluster:*"
        ]
        Resource = [
          aws_msk_cluster.main.arn,
          "${aws_msk_cluster.main.arn}/*"
        ]
      },
      {
        Sid    = "MSKClusterManagement"
        Effect = "Allow"
        Action = [
          "kafka:Describe*",
          "kafka:List*",
          "kafka:Get*",
          "kafka:Update*",
          "kafka:Reboot*"
        ]
        Resource = aws_msk_cluster.main.arn
      },
      {
        Sid    = "MSKConfigurationAccess"
        Effect = "Allow"
        Action = [
          "kafka:Describe*",
          "kafka:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "KMSOperationsForMSK"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.msk.arn
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:kafka:cluster-name" = var.name
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-msk-admin"
  })
}

resource "aws_iam_role_policy_attachment" "msk_admin" {
  role       = aws_iam_role.msk_admin.name
  policy_arn = aws_iam_policy.msk_admin.arn
}
