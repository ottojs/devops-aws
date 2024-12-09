
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "main" {
  name = var.name
  # TODO: Review
  image_tag_mutability = "MUTABLE" # IMMUTABLE
  force_delete         = true

  image_scanning_configuration {
    # TODO: Review
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key.arn
  }
}
