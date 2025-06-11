
locals {
  subnet_ids = [for s in var.subnets : s.id]
}

variable "name" {
  type = string
}

variable "public" {
  type    = bool
  default = false
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "subnets" {
  type    = list(object({ id = string }))
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "root_domain" {
  type = string
}

variable "log_bucket" {
  type = object({
    id  = string
    arn = string
  })
  description = "S3 Log Bucket Object"
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

variable "idle_timeout" {
  type        = number
  default     = 60
  description = "The time in seconds that the connection is allowed to be idle"
  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "idle_timeout must be between 1 and 4000 seconds"
  }
}

variable "dev_mode" {
  type        = bool
  default     = true
  description = "Enable development mode (disables deletion protection and enhanced monitoring)"
}

variable "tags" {
  type = map(string)
}
