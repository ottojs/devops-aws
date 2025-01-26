
# To Delete:
# aws ssm delete-document --name SSM-SessionManagerRunShell
resource "aws_ssm_document" "sessions" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Session Manager Settings"
    sessionType   = "Standard_Stream"
    inputs = {
      kmsKeyId                    = var.kms_key.arn
      s3BucketName                = var.log_bucket.id
      s3KeyPrefix                 = "devops/aws/ssm/sessions"
      s3EncryptionEnabled         = true
      cloudWatchLogGroupName      = "devops/aws/ssm/sessions"
      cloudWatchEncryptionEnabled = true
      cloudWatchStreamingEnabled  = true
      idleSessionTimeout          = 10
      maxSessionDuration          = 60
      runAsEnabled                = false
      shellProfile = {
        linux   = ""
        windows = ""
      }
    }
  })
}

resource "aws_cloudwatch_log_group" "ssm_sessions" {
  name              = "devops/aws/ssm/sessions"
  kms_key_id        = var.kms_key.arn
  skip_destroy      = true
  retention_in_days = var.log_retention_days
}
