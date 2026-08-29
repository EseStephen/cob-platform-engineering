variable "project" {
  description = "Name of the project or application."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "s3_bucket_name" {
  description = "S3 bucket containing the data to be queried."
  type        = string
}

variable "database_name" {
  description = "Glue Data Catalog database name."
  type        = string
  default     = "analytics"
}

variable "athena_query_results_bucket" {
  description = "S3 bucket where Athena query results are stored."
  type        = string
}