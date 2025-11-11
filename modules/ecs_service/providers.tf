
terraform {
  required_version = ">= 1.10"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
    }
  }
}
