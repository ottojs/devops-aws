data "aws_region" "current" {}

# # Using the VPN? Set this to your IP(s)
# # https://whatismyipaddress.com/
# variable "vpn_cidrs" {
#   type = list(string)
#   default = ["YOURIPHERE/32"]
# }

# Disabled. You should use the AWS Console Web SSH interface instead
# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
# resource "aws_key_pair" "main" {
#   key_name   = "main"
#   public_key = "ssh-rsa ...REPLACE ME..."
# }

# This is used to make S3 bucket names more unique
# It will be appended to the end of the name
variable "random_id" {
  type    = string
  default = "RANDOM-ID-HERE-FROM-STEP-1"
}

variable "root_domain" {
  type    = string
  default = "example.com"
}

variable "log_retention_days" {
  type    = number
  default = 365
}

variable "email" {
  type = string
  # Uncomment and update this value with your email
  # This is used to subscribe to the devops SNS topic alerts
  # default = "user@example.com"
}

# password must contain at least one:
# - uppercase letter
# - lowercase letter
# - number
# - special character
variable "opensearch_password" {
  type    = string
  default = "REPLACEME"
}

# You can use "checksum" to track and dynamically update tags
# If you change the checksum and immediately run an "apply"
# You'll be able to detect which resources are not in the pipeline
variable "tags" {
  type = map(string)
  default = {
    App      = "DEVOPS-CORE"
    Owner    = "otto"
    Checksum = "abc123"
  }
}
