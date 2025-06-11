
# Public Bucket
# Block Non-TLS Connections
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "main" {
  # statement {
  #   sid       = "PublicReadOnly"
  #   effect    = "Allow"
  #   actions   = ["s3:GetObject"]
  #   resources = ["${aws_s3_bucket.main.arn}/*"]
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }
  #   condition {
  #     test     = "Bool"
  #     variable = "aws:SecureTransport"
  #     values   = ["true"]
  #   }
  # }

  # Bucket Listing
  # Deny Public
  # Allow Account Users/Roles
  statement {
    sid       = "ListingDenyPublic"
    effect    = "Deny"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.main.arn]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*",
      ]
    }
  }

  statement {
    sid     = "DenyNonTLSRequests"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*"
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
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.main.arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

# Policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  # You can also direct-attach
  # policy = jsonencode({})
  policy     = data.aws_iam_policy_document.main.json
  depends_on = [aws_s3_bucket_public_access_block.main]
}

# Lifecycle
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.main]
  bucket     = aws_s3_bucket.main.id

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
    # WARNING: This will delete ALL files in the bucket after the specified days
    # For public website buckets, this should remain 0 (disabled) to prevent
    # accidental deletion of your website content (HTML, CSS, JS, images, etc.)
    expiration {
      days = var.delete_days_files
    }
  }
}
