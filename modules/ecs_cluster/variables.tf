
variable "name" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

# https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_PutRetentionPolicy.html#API_PutRetentionPolicy_RequestSyntax
variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention period in days"
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.log_retention_days)
    error_message = "log_retention_days must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, or 3653 days"
  }
}

variable "asg" {
  type = object({
    name                  = string
    arn                   = string
    protect_from_scale_in = bool
  })
  default = {
    name                  = "default"
    arn                   = "default"
    protect_from_scale_in = false
  }
}

# FARGATE or EC2
variable "type" {
  type = string
}

variable "tags" {
  type = map(string)
}
