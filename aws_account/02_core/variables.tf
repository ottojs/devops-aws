data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Set this to your IP
# https://whatismyipaddress.com/
variable "allowed_cidrs" {
  type = list(string)
  default = [
    "YOURIPHERE/32"
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "main" {
  key_name   = "main"
  public_key = "ssh-rsa ...REPLACE ME..."
}

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

variable "tag_app" {
  type    = string
  default = "DEVOPS-MAIN"
}
