
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account
data "aws_elb_service_account" "main" {}

# Logging Bucket. Require TLS, Allow ELB Logs
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "log_bucket" {
  statement {
    sid     = "DenyNonTLSRequests"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.bucket_private.arn,
      "${aws_s3_bucket.bucket_private.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid       = "AllowELBAccountPutObject"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket_private.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn] # root
    }
  }

  statement {
    sid       = "AllowLogServiceGetAcl"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.bucket_private.arn]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowLogServicePutObject"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket_private.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

# Normal Bucket
# Block Non-TLS Connections
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "normal" {
  statement {
    sid     = "DenyNonTLSRequests"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.bucket_private.arn,
      "${aws_s3_bucket.bucket_private.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.bucket_private.id
  policy = var.log_bucket_disabled ? data.aws_iam_policy_document.log_bucket.json : data.aws_iam_policy_document.normal.json
  # You can also direct-attach
  # policy = jsonencode({})
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
