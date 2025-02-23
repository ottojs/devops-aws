
# Before First Run
# tofu init
#
# After Upgrades or Additions
# tofu init -upgrade

terraform {
  required_version = ">= 1.9"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "5.88.0"
    }
  }
}
