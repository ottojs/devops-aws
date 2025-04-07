
##########################
##### AWS Config IAM #####
##########################

# Alternative:
# Role: AWSServiceRoleForConfig
# Policy: AWSConfigServiceRolePolicy
# This will allow AWS to manage the policy
#
# resource "aws_iam_service_linked_role" "config" {
#   aws_service_name = "config.amazonaws.com"
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "awsconfig" {
  name               = "devops-aws-config-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "awsconfig" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      module.aws_config_bucket.bucket.arn,
      "${module.aws_config_bucket.bucket.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [module.aws_config_bucket.bucket.arn]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "awsconfig" {
  name   = "devops-aws-config-policy"
  role   = aws_iam_role.awsconfig.id
  policy = data.aws_iam_policy_document.awsconfig.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment
resource "aws_iam_role_policy_attachment" "config_managed_policy" {
  role       = aws_iam_role.awsconfig.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRulesExecutionRole"
}
