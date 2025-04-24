
# Requires 1 day timeout after deletion before creating a new index
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourceexplorer2_index
resource "aws_resourceexplorer2_index" "main" {
  type = "AGGREGATOR" # "LOCAL"
  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourceexplorer2_view
resource "aws_resourceexplorer2_view" "main" {
  name = "everything"
  default_view = true

  included_property {
    name = "tags"
  }

  tags = var.tags

  depends_on = [aws_resourceexplorer2_index.main]
}
