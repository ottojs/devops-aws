
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "ssm_sessions" {
  name              = local.log_name
  kms_key_id        = aws_kms_key.ssm.arn
  skip_destroy      = false
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_stream" "ssm_sessions" {
  name           = "ssm-session-logs"
  log_group_name = aws_cloudwatch_log_group.ssm_sessions.name
}
