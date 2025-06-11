
output "kms_key" {
  value = {
    id       = aws_kms_key.ssm.id
    arn      = aws_kms_key.ssm.arn
    alias_id = aws_kms_alias.ssm.id
  }
  description = "KMS key used by SSM module"
}

output "instance_profile" {
  value       = aws_iam_instance_profile.ec2
  description = "IAM instance profile for EC2 instances"
}

output "role_name" {
  value       = aws_iam_role.ec2.name
  description = "The name of the IAM role for EC2 instances"
}

output "role_arn" {
  value       = aws_iam_role.ec2.arn
  description = "The ARN of the IAM role for EC2 instances"
}

output "session_document_name" {
  value       = aws_ssm_document.sessions.name
  description = "The name of the SSM session document"
}

output "log_group_name" {
  value       = aws_cloudwatch_log_group.ssm_sessions.name
  description = "The CloudWatch log group name for SSM sessions"
}
