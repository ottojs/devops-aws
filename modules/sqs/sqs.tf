
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
resource "aws_sqs_queue" "main" {
  name = var.name
  # sqs_managed_sse_enabled   = true
  kms_master_key_id          = var.kms_key.id # "alias/aws/sqs"
  delay_seconds              = 0              # (max: 900 - 15 min)
  max_message_size           = 262144         # 256 KiB (max: 262144 - 256 KiB)
  message_retention_seconds  = 1209600        # 14 days (max: 1209600 - 14 days)
  receive_wait_time_seconds  = 20             # seconds (max: 20)
  visibility_timeout_seconds = 60             # seconds (max: 43200 - 12 days)

  tags = merge(var.tags, {
    Name = var.name
  })
}
