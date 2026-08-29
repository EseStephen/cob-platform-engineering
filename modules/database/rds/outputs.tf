output "db_instance_id" {
  description = "ID of the RDS database instance."
  value       = aws_db_instance.this.id
}

output "db_endpoint" {
  description = "DNS endpoint of the RDS database."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Port used by the PostgreSQL database."
  value       = aws_db_instance.this.port
}

output "security_group_id" {
  description = "Security group ID protecting the RDS database."
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "Name of the RDS subnet group."
  value       = aws_db_subnet_group.this.name
}