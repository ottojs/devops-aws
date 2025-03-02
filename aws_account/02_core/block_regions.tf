
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_deny-requested-region.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "policy" {
  name        = "block-regions"
  path        = "/"
  description = "Blocks non-US regions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        NotAction = [
          "cloudfront:*",
          "iam:*",
          "route53:*",
          "support:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" : [
              "us-east-1",
              "us-east-2",
              "us-west-1",
              "us-west-2",
            ]
          }
        }
      },
    ]
  })
}
