# Before First Run
# tofu init
#
# After Upgrades or Additions
# tofu init -upgrade

terraform {
  required_version = ">= 1.10"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
    }
  }
  backend "s3" {
    bucket         = "devops-terraform-state-bucket-${var.random_id}"
    region         = "us-east-1"
    key            = "core/terraform.tfstate"
    dynamodb_table = "devops-terraform-state"
  }
}

provider "aws" {
  # DO NOT USE
  # access_key
  # secret_key
  # token
  # Use credential files/roles instead
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-configuration-and-credentials-files
}
