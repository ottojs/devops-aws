
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
resource "aws_flow_log" "flowlogs" {
  iam_role_arn    = aws_iam_role.flowlogs.arn
  log_destination = aws_cloudwatch_log_group.flowlogs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "flowlogs" {
  name       = "vpc/flow-logs/${aws_vpc.main.id}"
  kms_key_id = var.kms_key.arn
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "flowlogs" {
  name               = "tf-role-vpc-flow-logs-${aws_vpc.main.id}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "flowlogs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:AssociateKmsKey",
    ]
    resources = ["*"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "flowlogs" {
  name   = "tf-policy-vpc-flow-logs-${aws_vpc.main.id}"
  role   = aws_iam_role.flowlogs.id
  policy = data.aws_iam_policy_document.flowlogs.json
}
