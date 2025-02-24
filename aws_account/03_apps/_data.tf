data "aws_region" "current" {}

data "aws_kms_key" "main" {
  key_id = "alias/main"
}

data "aws_s3_bucket" "logging" {
  bucket = "devops-log-bucket-${var.random_id}"
}

data "aws_vpc" "main" {
  tags = {
    Name = "vpc-main"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Public"
    values = ["false"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Public"
    values = ["true"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb
data "aws_lb" "private" {
  name = "alb-private"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb
data "aws_lb" "public" {
  name = "alb-public"
}
