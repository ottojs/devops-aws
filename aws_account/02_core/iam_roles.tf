
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
  }
}

# Role - EC2/SSM
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ec2_session_manager" {
  name               = "tf-role-ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Policy - EC2/SSM
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ec2_session_manager" {
  role = aws_iam_role.ec2_session_manager.name
  # This is too lightweight and does not support encrypted CloudWatch/S3 Encrypted Logs
  # policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# Instance Profile (from Role)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "ec2_session_manager" {
  name = "tf-EC2-Instance-Profile"
  role = aws_iam_role.ec2_session_manager.name
}
