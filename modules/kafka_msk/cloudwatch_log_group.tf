
# CloudWatch Log Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "msk" {
  count = var.dev_mode ? 0 : 1 # Always enable for production
  name  = "devops/msk/${var.name}"
  # TODO: Review
  retention_in_days = var.dev_mode ? 7 : 30 # 7 days for dev, 30 for production
  kms_key_id        = aws_kms_key.msk.arn   # Use the same KMS key for consistency

  tags = merge(var.tags, {
    Name = "devops/msk/${var.name}"
  })
}
