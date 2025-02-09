
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic
resource "aws_sns_topic" "main" {
  # name_prefix
  name                        = var.name
  display_name                = var.name
  kms_master_key_id           = var.kms_key.id # "alias/aws/sns"
  fifo_topic                  = false          # FIFO cannot deliver to email, sms, https
  content_based_deduplication = false
  signature_version           = 2 # SHA256
  tags                        = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
resource "aws_sns_topic_subscription" "main" {
  endpoint   = var.email
  protocol   = "email"
  topic_arn  = aws_sns_topic.main.arn
  depends_on = [aws_sns_topic.main]
}
