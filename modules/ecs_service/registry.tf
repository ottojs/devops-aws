
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "main" {
  count                = var.create_registry == true ? 1 : 0
  name                 = var.name
  image_tag_mutability = "IMMUTABLE" # or MUTABLE (not recommended)
  force_delete         = false

  image_scanning_configuration {
    # TODO: Review
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key.arn
  }
}
