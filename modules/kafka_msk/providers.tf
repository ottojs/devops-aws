
terraform {
  required_version = ">= 1.9"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
    # https://registry.terraform.io/providers/hashicorp/random/latest
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
