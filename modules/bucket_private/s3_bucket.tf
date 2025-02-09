
# TODO: Replication
# provider "aws" {
#   alias  = "us-west-1"
#   region = "us-west-1"
#   # provider = aws.us-west-1
# }

# Bucket
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "bucket_private" {
  bucket = "${var.name}-${var.random_id}"
  # TODO: Review
  force_destroy = true
  tags = {
    App = var.tag_app
  }
}

# Block Public Access
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "bucket_private" {
  bucket                  = aws_s3_bucket.bucket_private.id
  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
}

# Encryption
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_private" {
  bucket = aws_s3_bucket.bucket_private.id
  rule {
    # TODO: Disabling the CMK KMS key for now on log buckets
    # Load Balancer logs are not supported with KMS keys yet (or maybe ever)
    # https://repost.aws/questions/QU2SV2jkZRSkuhNL-EGUgyTA/storing-application-load-balancer-access-logs-in-a-kms-encrypted-s3-bucket
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.log_bucket_disabled ? null : var.kms_key.id
      sse_algorithm     = var.log_bucket_disabled ? "AES256" : "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Versioning
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
resource "aws_s3_bucket_versioning" "bucket_private" {
  bucket = aws_s3_bucket.bucket_private.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Logs
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging
resource "aws_s3_bucket_logging" "bucket_private" {
  count         = var.log_bucket_disabled ? 0 : 1
  bucket        = aws_s3_bucket.bucket_private.id
  target_bucket = var.log_bucket_id
  target_prefix = "devops/aws/s3/${var.name}-${var.random_id}/"
}
