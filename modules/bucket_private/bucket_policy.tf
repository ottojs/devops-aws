
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

  statement {
    sid       = "AllowLogExport1"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.bucket_private.arn]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowLogExport2"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket_private.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  #####################
  ##### Kafka MSK #####
  #####################
  statement {
    sid       = "DenyUnencryptedMSKLogs"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.log_bucket_id}/devops/msk/${var.name}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  statement {
    sid       = "DenyWrongKMSKeyForMSKLogs"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.log_bucket_id}/devops/msk/${var.name}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [aws_kms_key.msk.arn]
    }
  }

  statement {
    sid       = "AllowMSKToWriteLogs"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.log_bucket_id}/devops/msk/${var.name}/*"]
    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [aws_kms_key.msk.arn]
    }
  }

  statement {
    sid       = "AllowMSKToSetAcl"
    effect    = "Allow"
    actions   = ["s3:PutObjectAcl"]
    resources = ["arn:aws:s3:::${var.log_bucket_id}/devops/msk/${var.name}/*"]
    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
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

# Policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.bucket_private.id
  policy = var.log_bucket_disabled ? data.aws_iam_policy_document.log_bucket.json : data.aws_iam_policy_document.normal.json
  # You can also direct-attach
  # policy = jsonencode({})
  depends_on = [aws_s3_bucket_public_access_block.bucket_private]
}

# Lifecycle
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.bucket_private]
  bucket     = aws_s3_bucket.bucket_private.id

  rule {
    id     = "lifecycle-policy"
    status = "Enabled"
    filter {
      # Empty filter applies rule to entire bucket
      prefix = ""
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = var.delete_days_multipart
    }
    noncurrent_version_expiration {
      noncurrent_days = var.delete_days_old_versions
    }
    expiration {
      days = var.delete_days_files
    }
  }
}
