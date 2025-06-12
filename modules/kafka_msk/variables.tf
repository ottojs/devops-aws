data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "name" {
  type = string
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs for MSK brokers. Must be in different Availability Zones for high availability."
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets in different Availability Zones are required for high availability. For production deployments, 3 or more subnets are recommended."
  }
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic ARN for CloudWatch alarms"
}

variable "log_bucket_id" {
  type        = string
  description = "S3 bucket name for MSK broker logs. Required for all environments."
}

variable "log_retention_days" {
  type        = number
  default     = 400
  description = "Number of days to retain logs in S3. Applies lifecycle rule to the MSK logs prefix."
}

variable "kafka_version" {
  type    = string
  default = "4.0.x.kraft"
}

# Unfortunately v4.x only supports kafka.m5.large as the minimum instance size at time of writing
# Valid Values:
# - kafka.m5.large
# - kafka.m5.xlarge
# - kafka.m5.2xlarge
# - kafka.m5.4xlarge
# - kafka.m5.8xlarge
# - kafka.m5.12xlarge
# - kafka.m5.16xlarge
# - kafka.m5.24xlarge
variable "machine_type" {
  type        = string
  default     = "m5.large"
  description = "Instance type for production mode (without kafka. prefix). In dev_mode, always uses m5.large regardless of this setting."
}

variable "disk_size_initial" {
  type        = number
  default     = 10 # GB per broker
  description = "Initial disk size per broker. Storage autoscaling is always enabled (scales up to disk_size_max)"
}

variable "disk_size_max" {
  type        = number
  default     = 1000 # GB per broker
  description = "Maximum disk size per broker for autoscaling. Autoscaling triggers at 80% utilization"
}

variable "monitored_consumer_groups" {
  type = map(object({
    topic         = string
    lag_threshold = number
  }))
  default     = {}
  description = "Map of consumer groups to monitor for lag with their topic and threshold"
}

variable "compression_type" {
  type        = string
  default     = "snappy"
  description = "Default compression type for Kafka messages"
  validation {
    condition     = contains(["none", "gzip", "snappy", "lz4", "zstd"], var.compression_type)
    error_message = "Compression type must be one of: none, gzip, snappy, lz4, zstd"
  }
  # Compression options:
  # - none: No compression (highest throughput, highest storage/network usage)
  # - gzip: High compression ratio, higher CPU usage, good for cold storage
  # - snappy: Balanced compression/speed (recommended default)
  # - lz4: Fast compression, slightly less compression than snappy
  # - zstd: Best compression ratio with reasonable speed (Facebook's Zstandard)
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks allowed to connect to MSK cluster. Use security groups instead when possible."
}

variable "allowed_security_groups" {
  type = list(object({
    id   = string
    name = string
  }))
  default     = []
  description = "List of security groups allowed to connect to MSK cluster"
}

variable "sasl_scram_users" {
  type        = list(string)
  default     = []
  description = "List of SASL/SCRAM usernames to create. Passwords will be automatically generated and stored in AWS Secrets Manager."
}

variable "dev_mode" {
  type        = bool
  default     = true
  description = "Enable development mode for cost optimization"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional custom tags to apply to all resources"
}
