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

variable "subnet_ids" {
  description = "Private subnet IDs where ECS tasks will run."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two private subnets are required."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where ECS will run."
  type        = string
}

variable "container_image" {
  description = "Container image to run."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container."
  type        = number
  default     = 80
}

variable "cpu" {
  description = "Fargate CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate memory in MiB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 1
    error_message = "desired_count must be at least 1."
  }
}

variable "task_role_arn" {
  description = "IAM role assumed by the application running inside the ECS task."
  type        = string
  default     = null
}

variable "allowed_ingress_cidr" {
  description = "CIDR blocks allowed to access the container."
  type        = list(string)
  default     = []
}