data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket
data "aws_s3_bucket" "log_bucket" {
  bucket = "devops-log-bucket-${var.random_id}"
}

variable "cost_savings" {
  type    = bool
  default = false
}

variable "random_id" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

variable "inspector_resource_types" {
  type    = list(string)
  default = ["EC2", "ECR", "LAMBDA", "LAMBDA_CODE"]
}

variable "guardduty_s3" {
  type    = bool
  default = true
}

variable "guardduty_eks" {
  type    = bool
  default = true
}

variable "guardduty_ebs" {
  type    = bool
  default = true
}

variable "guardduty_ec2" {
  type    = bool
  default = true
}

variable "guardduty_fargate" {
  type    = bool
  default = true
}

variable "guardduty_rds" {
  type    = bool
  default = true
}

variable "guardduty_lambda" {
  type    = bool
  default = true
}

variable "max_credential_age" {
  type    = number
  default = 90
}

variable "tags" {
  type = map(string)
}
