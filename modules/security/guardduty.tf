
#####################
##### GuardDuty #####
#####################

# Documentation
# https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector
resource "aws_guardduty_detector" "main" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES" # "ONE_HOUR" "SIX_HOURS"
  # Deprecated, dont use datasources
  # datasources {}
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature
resource "aws_guardduty_detector_feature" "s3_data_events" {
  detector_id = aws_guardduty_detector.main.id
  name        = "S3_DATA_EVENTS"
  status      = var.guardduty_s3 == true ? "ENABLED" : "DISABLED"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature
resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  detector_id = aws_guardduty_detector.main.id
  name        = "EKS_AUDIT_LOGS"
  status      = var.guardduty_eks == true ? "ENABLED" : "DISABLED"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature
resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  detector_id = aws_guardduty_detector.main.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = var.guardduty_ebs == true ? "ENABLED" : "DISABLED"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature
resource "aws_guardduty_detector_feature" "rds_login_events" {
  detector_id = aws_guardduty_detector.main.id
  name        = "RDS_LOGIN_EVENTS"
  status      = var.guardduty_rds == true ? "ENABLED" : "DISABLED"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature
resource "aws_guardduty_detector_feature" "lambda_network_logs" {
  detector_id = aws_guardduty_detector.main.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = var.guardduty_lambda == true ? "ENABLED" : "DISABLED"
}

# This includes "EKS_RUNTIME_MONITORING" also, mutually exclusive
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature
resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  detector_id = aws_guardduty_detector.main.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = var.guardduty_eks == true ? "ENABLED" : "DISABLED"
  }

  additional_configuration {
    name   = "ECS_FARGATE_AGENT_MANAGEMENT"
    status = var.guardduty_fargate == true ? "ENABLED" : "DISABLED"
  }

  additional_configuration {
    name   = "EC2_AGENT_MANAGEMENT"
    status = var.guardduty_ec2 == true ? "ENABLED" : "DISABLED"
  }
}
