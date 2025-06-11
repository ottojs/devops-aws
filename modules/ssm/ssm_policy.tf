
locals {
  log_name = "devops/aws/ssm/sessions"
}

# To Delete:
# aws ssm delete-document --name SSM-SessionManagerRunShell
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document
resource "aws_ssm_document" "sessions" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Session Manager Settings"
    sessionType   = "Standard_Stream"
    inputs = {
      kmsKeyId                    = aws_kms_key.ssm.arn
      s3BucketName                = var.log_bucket.id
      s3KeyPrefix                 = local.log_name
      s3EncryptionEnabled         = true
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.ssm_sessions.name
      cloudWatchEncryptionEnabled = true
      cloudWatchStreamingEnabled  = true
      idleSessionTimeout          = 10
      maxSessionDuration          = 60
      runAsEnabled                = false
      # TODO
      #runAsEnabled                = true
      #runAsDefaultUser            = "ssm-user"
      shellProfile = {
        linux   = ""
        windows = ""
      }
    }
  })

  # Ensure CloudWatch log group and KMS key are created first
  depends_on = [
    aws_cloudwatch_log_group.ssm_sessions,
    aws_kms_key.ssm,
    aws_kms_alias.ssm
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "ssm_sessions" {
  name              = local.log_name
  kms_key_id        = aws_kms_key.ssm.arn
  skip_destroy      = false
  retention_in_days = var.log_retention_days
  tags              = var.tags
}
