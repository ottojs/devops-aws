
variable "allowed_regions" {
  description = "List of regions to allow"
  default = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
  ]
  type = list(string)
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for security alerts"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
