data "aws_region" "current" {}

locals {
  name = "${var.name}-${var.os}-${var.arch}"
}

variable "name" {
  type        = string
  description = "Name prefix for the EC2 instance and related resources"
}

variable "machine" {
  type        = string
  default     = ""
  description = "EC2 instance type (e.g., t3.micro). If empty, defaults based on architecture"
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

variable "ami" {
  type        = string
  default     = ""
  description = "Specific AMI ID to use. If empty, latest OS AMI will be selected"
}

variable "os" {
  type        = string
  default     = "al2023"
  description = "Operating system for the instance (al2023, rhel10, debian13, rocky10, etc.)"
}

variable "disk_size" {
  type        = number
  default     = 16
  description = "Size of the root EBS volume in GiB"
}

variable "ssh_key" {
  type        = string
  default     = ""
  description = "Name of the SSH key pair for instance access"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where the instance will be launched"
}

variable "public" {
  type        = bool
  default     = false
  description = "Whether to assign a public IP address to the instance"
}

variable "userdata" {
  type        = string
  description = "Path to user data script file"
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
  description = "KMS key for EBS volume encryption"
}

variable "security_groups" {
  type        = list(string)
  description = "List of security group IDs to attach to the instance"
}

variable "iam_instance_profile" {
  type = object({
    name = string
  })
  description = "IAM instance profile to attach to the instance"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to all resources"
}

variable "dev_mode" {
  type        = bool
  default     = true
  description = "Enable development mode (disables termination protection, recovery alarms, etc.)"
}
