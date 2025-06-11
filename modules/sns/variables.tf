data "aws_caller_identity" "current" {}

variable "name" {
  type        = string
  description = "Name of the SNS topic"
}

variable "email" {
  type        = string
  description = "Email address for SNS notifications"
  default     = null
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
  description = "KMS key for SNS topic encryption"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}
