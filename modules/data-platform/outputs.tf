output "glue_database_name" {
  description = "Name of the Glue Data Catalog database."
  value       = aws_glue_catalog_database.this.name
}

output "athena_workgroup_name" {
  description = "Name of the Athena workgroup."
  value       = aws_athena_workgroup.this.name
}