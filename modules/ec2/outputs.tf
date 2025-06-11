output "ec2" {
  value       = aws_instance.ec2
  description = "The complete EC2 instance resource"
}

output "instance_id" {
  value       = aws_instance.ec2.id
  description = "The ID of the EC2 instance"
}

output "private_ip" {
  value       = aws_instance.ec2.private_ip
  description = "The private IP address of the instance"
}

output "public_ip" {
  value       = aws_instance.ec2.public_ip
  description = "The public IP address of the instance (if applicable)"
}

output "availability_zone" {
  value       = aws_instance.ec2.availability_zone
  description = "The availability zone of the instance"
}

output "subnet_id" {
  value       = aws_instance.ec2.subnet_id
  description = "The subnet ID of the instance"
}

output "security_groups" {
  value       = aws_instance.ec2.vpc_security_group_ids
  description = "The security group IDs attached to the instance"
}

output "iam_instance_profile" {
  value       = aws_instance.ec2.iam_instance_profile
  description = "The IAM instance profile attached to the instance"
}

output "ami_id" {
  value       = aws_instance.ec2.ami
  description = "The AMI ID used by the instance"
}

output "instance_type" {
  value       = aws_instance.ec2.instance_type
  description = "The instance type"
}

output "arn" {
  value       = aws_instance.ec2.arn
  description = "The ARN of the EC2 instance"
}
