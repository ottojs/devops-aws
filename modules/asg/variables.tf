
locals {
  subnet_ids = [for s in var.subnets : s.id]
}

variable "name" {
  type = string
}

variable "subnets" {
  type = list(object({
    id                = string
    availability_zone = string
  }))
  validation {
    condition     = length(distinct([for s in var.subnets : s.availability_zone])) >= 2
    error_message = "Subnets must span at least 2 availability zones for high availability"
  }
}

variable "instance_type" {
  type = string
}

variable "ami" {
  type        = string
  default     = ""
  description = "Specific AMI ID to use. If empty, latest OS AMI will be selected"
}

variable "os" {
  type        = string
  default     = "al2023"
  description = "Operating system for the instance (al2023, rhel9, debian12, rocky9, etc.)"
}

variable "arch" {
  type        = string
  default     = "x86_64"
  description = "CPU architecture for the instance (x86_64 or arm64)"
  validation {
    condition     = contains(["x86_64", "arm64"], var.arch)
    error_message = "Architecture must be either x86_64 or arm64"
  }
}

variable "userdata_file" {
  type = string
}

variable "iam_instance_profile" {
  type = object({
    name = string
    arn  = string
  })
}

variable "security_groups" {
  type = list(string)
}

variable "count_min" {
  type    = number
  default = 1
}

variable "count_max" {
  type    = number
  default = 1
}

variable "seconds_warmup" {
  type    = number
  default = 120
}

variable "seconds_cooldown" {
  type    = number
  default = 120
}

variable "seconds_health" {
  type    = number
  default = 120
}

variable "scale_up_cpu" {
  type    = number
  default = 60
}

variable "root_volume_size" {
  type        = number
  default     = 16
  description = "Size of the root EBS volume in GB"
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
  description = "KMS Key Object for encrypting EBS"
}

variable "instance_refresh_min_healthy_percentage" {
  type        = number
  default     = 66
  description = "Minimum healthy percentage during instance refresh. Set to 66 for small ASGs (3 instances)"
}

variable "health_check_type" {
  type        = string
  default     = "EC2"
  description = "Type of health check to use. Valid values: EC2, ELB"
  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "Health check type must be either EC2 or ELB"
  }
}

variable "force_refresh_trigger" {
  description = "Change this value to force an instance refresh (e.g., timestamp, version)"
  type        = string
  default     = "v1"
}

variable "dev_mode" {
  type        = bool
  default     = false
  description = "Enable development mode (disables termination protection and conservative scaling)"
}

variable "tags" {
  type = map(string)
}

variable "enable_warm_pool" {
  type        = bool
  default     = false
  description = "Enable warm pool for faster scaling"
}

variable "warm_pool_size" {
  type        = number
  default     = 2
  description = "Maximum number of instances to maintain in the warm pool"
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic ARN for CloudWatch alarm notifications"
}

variable "cpu_high_threshold" {
  type        = number
  default     = 80
  description = "CPU utilization threshold for high CPU alarm"
}

variable "cpu_low_threshold" {
  type        = number
  default     = 5
  description = "CPU utilization threshold for low CPU alarm"
}

variable "memory_high_threshold" {
  type        = number
  default     = 80
  description = "Memory utilization threshold for high memory alarm"
}

variable "enable_memory_monitoring" {
  type        = bool
  default     = false
  description = "Enable memory monitoring (requires CloudWatch agent)"
}
