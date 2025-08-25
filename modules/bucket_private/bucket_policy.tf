
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account
data "aws_elb_service_account" "main" {}

###############################
##### Logging Bucket Only #####
###############################
# Block Non-TLS Connections
#
# Allow ELB Logs
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

  ##########################
  ##### SSM CloudTrail #####
  ##########################
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.bucket_private.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket_private.arn}/cloudtrail/ssm/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  #####################
  ##### Kafka MSK #####
  #####################
  statement {
    sid       = "DenyUnencryptedMSKLogs"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket_private.arn}/devops/aws/msk/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
      # ArnLike aws:SourceArn
    }
  }

  # This is disabled due to the MSK having its own key
  # The key is unknown at this stage of deployment and
  # may not even be needed, so this is here for reference
  # statement {
  #   sid       = "DenyWrongKMSKeyForMSKLogs"
  #   effect    = "Deny"
  #   actions   = ["s3:PutObject"]
  #   resources = ["${aws_s3_bucket.bucket_private.arn}/devops/aws/msk/*"]
  #   principals {
  #     type        = "*"
  #     identifiers = ["*"]
  #   }
  #   condition {
  #     test     = "StringNotEquals"
  #     variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
  #     values   = [MSK_KMS_ARN_HERE]
  #   }
  # }

  statement {
    sid       = "AllowMSKToSetAcl"
    effect    = "Allow"
    actions   = ["s3:PutObjectAcl"]
    resources = ["${aws_s3_bucket.bucket_private.arn}/devops/aws/msk/*"]
    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }
  }
}

###############################
##### Normal Bucket Only #####
###############################
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
