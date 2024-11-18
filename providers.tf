
# Before First Run
# tofu init
#
# After Upgrades or Additions
# tofu init -upgrade

terraform {
  required_version = ">= 1.8"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  # DO NOT USE
  # access_key
  # secret_key
  # token
  # Use credential files/roles instead
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-configuration-and-credentials-files
}
