
# Consumer Role - Can read from topics
resource "aws_iam_role" "msk_consumer" {
  name = "${var.name}-msk-consumer"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = local.default_trusted_services
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-msk-consumer"
  })
}

# Consumer Policy
resource "aws_iam_policy" "msk_consumer" {
  name        = "${var.name}-msk-consumer"
  path        = "/"
  description = "MSK consumer policy for ${var.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "MSKClusterAccess"
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster"
        ]
        Resource = aws_msk_cluster.main.arn
      },
      {
        Sid    = "MSKTopicReadAccess"
        Effect = "Allow"
        Action = [
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:ReadData"
        ]
        Resource = [
          "${aws_msk_cluster.main.arn}/topic/*"
        ]
      },
      {
        Sid    = "MSKConsumerGroupAccess"
        Effect = "Allow"
        Action = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ]
        Resource = "${aws_msk_cluster.main.arn}/group/consumer-*"
      },
      {
        Sid    = "KMSDecryptForMSK"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
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
    Name = "${var.name}-msk-consumer"
  })
}

resource "aws_iam_role_policy_attachment" "msk_consumer" {
  role       = aws_iam_role.msk_consumer.name
  policy_arn = aws_iam_policy.msk_consumer.arn
}

resource "aws_iam_instance_profile" "msk_consumer" {
  name = "${var.name}-msk-consumer"
  role = aws_iam_role.msk_consumer.name

  tags = merge(var.tags, {
    Name = "${var.name}-msk-consumer"
  })
}
