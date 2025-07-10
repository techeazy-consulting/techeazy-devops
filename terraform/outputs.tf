output "public-ip-address" {
  value = aws_instance.instance1.public_ip
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.instance1.id
}