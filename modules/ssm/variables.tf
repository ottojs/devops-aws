data "aws_region" "current" {}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
  description = "KMS Key Object"
}

variable "log_bucket" {
  type = object({
    id = string
  })
}

variable "log_retention_days" {
  type = number
}

variable "tags" {
  type = map(string)
}
