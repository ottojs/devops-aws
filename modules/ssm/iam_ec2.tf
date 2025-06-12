
# TODO: CloudWatchAgentServerPolicy

# Allow EC2 Instances to Assume Role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

# Role - EC2/SSM
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ec2" {
  name               = "ec2-ssm"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.tags
}

# Policy - EC2/SSM
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ec2_session_manager" {
  role = aws_iam_role.ec2.name
  # This is too lightweight and does not support encrypted CloudWatch/S3 Encrypted Logs
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  # This is deprecated / unusable
  # policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# Policy - EC2/SSM access S3
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Policy - EC2/SSM access CloudWatch Logs
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_logs" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Policy - EC2/SSM access ECR
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ec2_ecr" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# Policy - EC2/SSM access EC2 Read Only
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ec2_readonly" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# TODO: May not be needed
# Policy - ECS Self-Hosted AutoScaling Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ec2_ecs" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Instance Profile (from Role)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "ec2" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2.name
  tags = var.tags
}

# Inline Policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy.html
resource "aws_iam_role_policy" "inline" {
  name = "custom-inline"
  role = aws_iam_role.ec2.name
  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid = "CustomizedBastion"
        Action = [
          "iam:PassRole",
          "kafka-cluster:*",
          "kms:*",
          "rds:*",
          "secretsmanager:*",
          "sts:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
