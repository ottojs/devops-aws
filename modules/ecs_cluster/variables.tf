
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
  description = "Auto Scaling Group configuration for EC2 launch type. Note: EBS encryption should be configured in the ASG launch template"
}

# FARGATE or EC2
variable "type" {
  type = string
  validation {
    condition     = contains(["FARGATE", "EC2"], var.type)
    error_message = "Type must be either FARGATE or EC2"
  }
}

variable "dev_mode" {
  type        = bool
  default     = false
  description = "Enable development mode (disables skip_destroy for logs and reduces security settings)"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags. Required: Owner"
  validation {
    condition = alltrue([
      contains(keys(var.tags), "Owner"),
    ])
    error_message = "Required tags missing. Must include: Owner"
  }
}

# CloudWatch Alarm Variables

variable "cpu_threshold_high" {
  type        = number
  default     = 70
  description = "CPU utilization threshold for high alarm"
}

variable "memory_threshold_high" {
  type    = number
  default = 70
}

variable "min_running_tasks_threshold" {
  type        = number
  default     = 1
  description = "Minimum number of running tasks before triggering alarm"
}

variable "gpu_threshold_high" {
  type        = number
  default     = 50
  description = "GPU utilization threshold for high alarm"
}

# EC2 Only

variable "failed_task_threshold" {
  type        = number
  default     = 5
  description = "Number of failed tasks to trigger alarm"
}

variable "min_container_instances_threshold" {
  type        = number
  default     = 1
  description = "Minimum number of container instances"
}
