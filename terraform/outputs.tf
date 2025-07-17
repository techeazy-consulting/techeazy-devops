output "active_stage" {
  value = var.stage
}

output "public-ip-address" {
  value = aws_instance.example1.public_ip
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.example1.id
}

output "readonly_public_ip" {
  description = "Public IP of ReadOnly EC2 instance"
  value       = length(aws_instance.readonly_ec2) > 0 ? aws_instance.readonly_ec2[0].public_ip : null
}

output "repo_url" {
  description = "GitHub repository URL"
  value       = local.config.repo_url
}
