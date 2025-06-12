
# Producer Role - Can write to topics
resource "aws_iam_role" "msk_producer" {
  name = "${var.name}-msk-producer"
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
    Name = "${var.name}-msk-producer"
  })
}

# Producer Policy
resource "aws_iam_policy" "msk_producer" {
  name        = "${var.name}-msk-producer"
  path        = "/"
  description = "MSK producer policy for ${var.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "MSKClusterAccess"
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:AlterCluster",
          "kafka-cluster:DescribeCluster"
        ]
        Resource = aws_msk_cluster.main.arn
      },
      {
        Sid    = "MSKTopicWriteAccess"
        Effect = "Allow"
        Action = [
          "kafka-cluster:CreateTopic",
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:AlterTopic",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData",
          "kafka-cluster:DescribeGroup"
        ]
        Resource = [
          "${aws_msk_cluster.main.arn}/topic/*"
        ]
      },
      {
        Sid    = "MSKProducerGroupAccess"
        Effect = "Allow"
        Action = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ]
        Resource = "${aws_msk_cluster.main.arn}/group/producer-*"
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
    Name = "${var.name}-msk-producer"
  })
}

resource "aws_iam_role_policy_attachment" "msk_producer" {
  role       = aws_iam_role.msk_producer.name
  policy_arn = aws_iam_policy.msk_producer.arn
}

# Instance profile for EC2 instances
resource "aws_iam_instance_profile" "msk_producer" {
  name = "${var.name}-msk-producer"
  role = aws_iam_role.msk_producer.name

  tags = merge(var.tags, {
    Name = "${var.name}-msk-producer"
  })
}
