
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy.html
resource "aws_iam_account_password_policy" "strict" {
  allow_users_to_change_password = true # Only if unexpired
  hard_expiry                    = true # Require admin to reset if expired
  max_password_age               = 90   # in days
  minimum_password_length        = 32
  password_reuse_prevention      = 24
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  require_uppercase_characters   = true
}
