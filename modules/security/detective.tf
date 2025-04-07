
#####################
##### Detective #####
#####################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/detective_graph
resource "aws_detective_graph" "main" {
  tags = merge(var.tags, {
    Name = "detective-graph"
  })
}
