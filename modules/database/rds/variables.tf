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

variable "vpc_id" {
  description = "ID of the VPC where the database will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required for the RDS subnet group."
  }
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "17"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial database storage in GB."
  type        = number
  default     = 20
}

variable "database_name" {
  description = "Name of the application database."
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Master username for the database."
  type        = string
  default     = "cobadmin"
}

variable "allowed_security_group_id" {
  description = "Security group allowed to connect to PostgreSQL."
  type        = string
}

variable "multi_az" {
  description = "choose to deploy the database using Multi-AZ."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days automated backups are retained."
  type        = number
  default     = 7
}