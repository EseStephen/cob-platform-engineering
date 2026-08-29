locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "COB"
  }
}

# Glue Data Catalog database
resource "aws_glue_catalog_database" "this" {
  name = "${var.project}_${var.environment}_${var.database_name}"

  description = "COB-managed analytics catalog for ${var.project}"

  tags = local.common_tags
}

# Athena workgroup provides a standard query environment
resource "aws_athena_workgroup" "this" {
  name = "${var.project}-${var.environment}-analytics"

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = "s3://${var.athena_query_results_bucket}/athena-results/"
    }
  }

  tags = local.common_tags
}