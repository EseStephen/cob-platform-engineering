output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Security group ID created for the workload."
  value       = aws_security_group.this.id
}