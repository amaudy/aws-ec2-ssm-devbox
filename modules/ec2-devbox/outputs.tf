output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.devbox.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.devbox.arn
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.devbox.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.devbox.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.devbox_role.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.devbox.name
}
