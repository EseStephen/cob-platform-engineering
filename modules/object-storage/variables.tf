variable "project" {
  description = "Name of the project or application using the storage capability."
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

variable "versioning_enabled" {
  description = "Choose whether S3 object versioning should be enabled."
  type        = bool
  default     = true
}