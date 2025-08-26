
# Basic Configuration
variable "name" {
  type        = string
  description = "Name for the Aurora MySQL instance"
}

variable "dev_mode" {
  type        = bool
  description = "Enable development mode (disables enhanced monitoring, deletion protection, longer backups, performance insights, etc.)"
  default     = true
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
  description = "VPC configuration"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for DB subnet group (minimum 2 in different AZs)"
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs in different AZs are required"
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the cluster"
  default     = []
}

# Database Configuration
variable "engine_version" {
  type        = string
  description = "Aurora MySQL engine version"
  default     = "8.0.mysql_aurora.3.10.0"
  # To find available versions: aws rds describe-db-engine-versions --engine aurora-mysql --query "DBEngineVersions[].EngineVersion"
}

variable "database_name" {
  type        = string
  description = "Name of the default database to create"
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "Admin username for the database"
  default     = "customadmin"
}

# This is a path to secret in Secrets Manager, do not put password here
variable "admin_password" {
  type        = string
  description = "Admin password for the database, path to secret in Secrets Manager"
}

# Instance Configuration
variable "instance_class" {
  type        = string
  description = "Instance class for the primary instance"
  default     = "t4g.medium"
  # Common options: db.t3.medium, db.t4g.large, db.r6g.large, db.r6g.xlarge
}

# Reader Instance Configuration
variable "reader_instance_count" {
  type        = number
  description = "Number of reader instances to create (0 to disable reader instances)"
  default     = 0
  validation {
    condition     = var.reader_instance_count >= 0 && var.reader_instance_count <= 15
    error_message = "Reader instance count must be between 0 and 15"
  }
}

variable "reader_instance_class" {
  type        = string
  description = "Instance class for reader instances (defaults to same as primary)"
  default     = ""
}

# Security Configuration
variable "kms_key_id" {
  type        = string
  description = "KMS key ID for encryption at rest"
}

# Backup Configuration (Override with dev_mode)

variable "backup_retention_period_days" {
  type        = number
  description = "Backup retention period in days for production (dev_mode uses 7 days)"
  default     = 35
  validation {
    condition     = var.backup_retention_period_days >= 1 && var.backup_retention_period_days <= 35
    error_message = "Backup retention period must be between 1 and 35 days (use AWS Backup for longer retention)"
  }
}

variable "backup_window" {
  type        = string
  description = "Preferred backup window (UTC)"
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  type        = string
  description = "Preferred maintenance window"
  default     = "sun:04:00-sun:05:00"
}

variable "backtrack_window_hours" {
  type        = number
  description = "Target backtrack window in hours (0-72). Enables fast database rewind without restoring from backup. Set to 0 to disable"
  default     = 0
  validation {
    condition     = var.backtrack_window_hours >= 0 && var.backtrack_window_hours <= 72
    error_message = "Backtrack window must be between 0 and 72 hours"
  }
}

# Monitoring Configuration (Override with dev_mode)

# CloudWatch Monitoring Configuration

variable "sns_topic" {
  type = object({
    arn = string
  })
  description = "SNS topic for alarms and event notifications (required)"
}

variable "cpu_threshold_high" {
  type        = number
  description = "CPU utilization threshold for alarm (%)"
  default     = 80
}

variable "connections_threshold_high" {
  type        = number
  description = "Database connections threshold for alarm"
  default     = 800
}

variable "memory_threshold_low_bytes" {
  type        = number
  description = "Freeable memory threshold for alarm (bytes)"
  default     = 1073741824 # 1 GB
}

variable "storage_threshold_low_bytes" {
  type        = number
  description = "Free local storage threshold for alarm (bytes)"
  default     = 10737418240 # 10 GB
}

variable "read_latency_threshold_ms" {
  type        = number
  description = "Read latency threshold for alarm (milliseconds)"
  default     = 200
}

variable "write_latency_threshold_ms" {
  type        = number
  description = "Write latency threshold for alarm (milliseconds)"
  default     = 200
}

variable "deadlock_threshold" {
  type        = number
  description = "Deadlock count threshold for alarm"
  default     = 1
}

# Event Subscription Configuration
variable "cluster_event_categories" {
  type        = list(string)
  description = "List of event categories for cluster events"
  default = [
    "configuration change",
    "creation",
    "deletion",
    "failover",
    "failure",
    "global-failover",
    "maintenance",
    "notification",
    "recovery",
  ]
  validation {
    condition = alltrue([
      for cat in var.cluster_event_categories : contains([
        "configuration change",
        "creation",
        "deletion",
        "failover",
        "failure",
        "global-failover",
        "maintenance",
        "notification",
        "recovery",
      ], cat)
    ])
    error_message = "Invalid cluster event category specified"
  }
}

variable "instance_event_categories" {
  type        = list(string)
  description = "List of event categories for instance events"
  default = [
    "availability",
    "backup",
    "configuration change",
    "creation",
    "deletion",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "read replica",
    "recovery",
    "restoration",
  ]
  validation {
    condition = alltrue([
      for cat in var.instance_event_categories : contains([
        "availability",
        "backup",
        "configuration change",
        "creation",
        "deletion",
        "failure",
        "low storage",
        "maintenance",
        "notification",
        "read replica",
        "recovery",
        "restoration",
      ], cat)
    ])
    error_message = "Invalid instance event category specified"
  }
}

# CloudWatch Logs Configuration
variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days for all log types (0 = never expire)"
  validation {
    condition = contains([
      0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention must be one of the valid CloudWatch retention values"
  }
}

# AWS Backup Configuration
variable "enable_aws_backup" {
  type        = bool
  description = "Enable AWS Backup integration by adding backup tags. Set to true when AWS Backup is configured"
  default     = false
}

variable "backup_plan_name" {
  type        = string
  description = "Name of the AWS Backup plan to associate with this database (only used when enable_aws_backup is true)"
  default     = "default"
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
