output "ami_id" {
  description = "The ID of the most recent AMI matching the criteria"
  value       = data.aws_ami.main.id
}

output "ami_name" {
  description = "The name of the most recent AMI"
  value       = data.aws_ami.main.name
}

output "ami_architecture" {
  description = "The architecture of the AMI (x86_64 or arm64)"
  value       = data.aws_ami.main.architecture
}
