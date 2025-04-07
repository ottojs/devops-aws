
########################
##### Security Hub #####
########################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account
resource "aws_securityhub_account" "main" {
  enable_default_standards = true
  auto_enable_controls     = true
}
