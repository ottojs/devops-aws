
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
