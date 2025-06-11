data "aws_region" "current" {}

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

variable "waf_rate_limit" {
  type        = number
  default     = 250
  description = "Maximum number of requests from a single IP in a 5-minute period"
}

variable "waf_rate_limit_action" {
  type        = string
  default     = "block"
  description = "Action to take when rate limit is exceeded: block or count"
  validation {
    condition     = contains(["block", "count"], var.waf_rate_limit_action)
    error_message = "waf_rate_limit_action must be either 'block' or 'count'"
  }
}

variable "waf_geo_blocking_enabled" {
  type        = bool
  default     = true
  description = "Enable geo-blocking for sanctioned and high-risk countries"
}

variable "waf_blocked_countries" {
  type = list(string)
  default = [
    "CU", # Cuba
    "IR", # Iran
    "KP", # North Korea
    "SY", # Syria
    "RU", # Russia
    "BY", # Belarus
    "VE", # Venezuela
    "CN", # China
    "MM"  # Myanmar/Burma
  ]
  # https://www.iban.com/country-codes
  description = "List of country codes to block (ISO 3166-1 alpha-2)"
}

variable "waf_geo_blocking_action" {
  type        = string
  default     = "block"
  description = "Action to take for geo-blocked countries: block or count"
  validation {
    condition     = contains(["block", "count"], var.waf_geo_blocking_action)
    error_message = "waf_geo_blocking_action must be either 'block' or 'count'"
  }
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic ARN for CloudWatch alarm notifications. If empty, no alarms will be created."
}

variable "alarm_request_count_threshold" {
  type        = number
  default     = 10000
  description = "Threshold for request count alarm (requests per 5 minutes)"
}

variable "alarm_4xx_error_rate_threshold" {
  type        = number
  default     = 10
  description = "Threshold for 4xx error rate alarm (percentage)"
}

variable "alarm_5xx_error_rate_threshold" {
  type        = number
  default     = 5
  description = "Threshold for 5xx error rate alarm (percentage)"
}

variable "alarm_target_response_time_threshold" {
  type        = number
  default     = 3
  description = "Threshold for target response time alarm (seconds)"
}
