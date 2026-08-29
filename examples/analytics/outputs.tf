output "vpc_id" {
  description = "ID of the VPC."
  value       = module.networking.vpc_id
}

output "storage_bucket_name" {
  description = "Name of the S3 bucket."
  value       = module.storage.bucket_name
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster."
  value       = module.application.cluster_id
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = module.application.service_name
}

output "database_endpoint" {
  description = "RDS database endpoint."
  value       = module.database.db_endpoint
}