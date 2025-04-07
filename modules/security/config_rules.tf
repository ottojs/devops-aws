
############################
##### AWS Config Rules #####
############################

# Pricing:
# https://aws.amazon.com/config/pricing/
#
# List of Rules
# https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
#
# Some Rules:
# IAM_ROOT_ACCESS_KEY_CHECK
# IAM_USER_MFA_ENABLED
# EC2_INSTANCE_NO_PUBLIC_IP
# S3_BUCKET_VERSIONING_ENABLED
# S3_BUCKET_PUBLIC_WRITE_PROHIBITED
# S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED
# S3_BUCKET_LOGGING_ENABLED
# VPC_FLOW_LOGS_ENABLED
# EC2_SECURITY_GROUP_ATTACHED_TO_ENI
# RESTRICTED_SSH
# IAM_PASSWORD_POLICY
# IAM_USER_UNUSED_CREDENTIALS_CHECK
# EBS_IN_BACKUP_PLAN
# EC2_INSTANCE_MANAGED_BY_SSM

# We'll add more as we go
# For now, only using the basics

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule
resource "aws_config_config_rule" "iam_root_access_key_check" {
  name = "custom-iam-root-access-key-check"
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule
resource "aws_config_config_rule" "iam_password_policy" {
  name = "custom-iam-password-policy"
  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule
resource "aws_config_config_rule" "iam_user_unused_credentials_check" {
  name = "custom-iam-user-unused-credentials-check"
  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  }
  input_parameters = jsonencode({
    # Number values must be a string
    maxCredentialUsageAge = tostring(var.max_credential_age)
  })
  depends_on = [aws_config_configuration_recorder.main]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule
resource "aws_config_config_rule" "vpc_flow_logs_enabled" {
  name = "custom-vpc-flow-logs-enabled"
  source {
    owner             = "AWS"
    source_identifier = "VPC_FLOW_LOGS_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule
resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "custom-s3-bucket-versioning"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule
resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name = "custom-s3-bucket-server-side-encryption-enabled"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule
resource "aws_config_config_rule" "s3_bucket_logging_enabled" {
  name = "custom-s3-bucket-logging-enabled"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LOGGING_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}
