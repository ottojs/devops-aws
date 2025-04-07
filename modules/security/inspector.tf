
#####################
##### Inspector #####
#####################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_enabler
resource "aws_inspector2_enabler" "main" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = var.inspector_resource_types
}
