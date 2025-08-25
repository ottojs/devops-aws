
# Disabled as this will overwrite existing policy (on our log bucket)
# Leaving it here in case you want a separate bucket
#
# # Create lifecycle rule for log retention
# resource "aws_s3_bucket_lifecycle_configuration" "msk_logs" {
#   bucket = var.log_bucket_id

#   rule {
#     id     = "msk-${var.name}-retention"
#     status = "Enabled"

#     filter {
#       prefix = "devops/aws/msk/${var.name}/"
#     }

#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }

#     transition {
#       days          = 90
#       storage_class = "GLACIER"
#     }

#     expiration {
#       days = var.log_retention_days
#     }

#     noncurrent_version_expiration {
#       noncurrent_days = 7
#     }
#   }
# }
