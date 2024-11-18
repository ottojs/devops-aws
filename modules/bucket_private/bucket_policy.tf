
# Block Non-TLS Connections
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "enforce_tls" {
  bucket = aws_s3_bucket.bucket_private.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "AllowSSLRequestsOnly",
        Action = "s3:*"
        Effect = "Deny"
        Resource = [
          aws_s3_bucket.bucket_private.arn,
          "${aws_s3_bucket.bucket_private.arn}/*"
        ],
        Condition : {
          Bool : {
            "aws:SecureTransport" : "false"
          }
        },
        Principal : "*"
      },
    ]
  })
}

# Lifecycle
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-config" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.bucket_private]
  bucket     = aws_s3_bucket.bucket_private.id
  rule {
    id     = "expire-old"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
