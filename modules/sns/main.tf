
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic
resource "aws_sns_topic" "main" {
  # name_prefix
  name                        = var.name
  display_name                = var.name
  kms_master_key_id           = var.kms_key.id
  fifo_topic                  = false # FIFO cannot deliver to email, sms, https
  content_based_deduplication = false
  signature_version           = 2 # SHA256
  tags = merge(var.tags, {
    Name = var.name
  })

  # lifecycle {
  #   prevent_destroy = true
  # }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy
resource "aws_sns_topic_policy" "main" {
  arn = aws_sns_topic.main.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.name}-topic-policy"
    Statement = [
      {
        Sid    = "AllowAccountPublish"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.main.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.main.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
resource "aws_sns_topic_subscription" "main" {
  endpoint               = var.email
  protocol               = "email"
  topic_arn              = aws_sns_topic.main.arn
  endpoint_auto_confirms = false
  raw_message_delivery   = false
}
