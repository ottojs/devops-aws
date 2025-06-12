
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
      kmsKeyId                    = "alias/ssm-${data.aws_region.current.region}"
      s3BucketName                = var.log_bucket.id
      s3KeyPrefix                 = "${local.log_name}/$${aws:username}/$${aws:sessionid}"
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
