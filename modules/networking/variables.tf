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

variable "vpc_cidr" {
  description = "CIDR block for the VPC. COB v1 expects a /16 network."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition = (
      can(cidrhost(var.vpc_cidr, 0)) &&
      tonumber(split("/", var.vpc_cidr)[1]) == 16
    )

    error_message = "vpc_cidr must be a valid /16 CIDR block."
  }
}

variable "enable_nat_gateway" {
  description = "Whether private subnets require outbound internet access through a NAT Gateway."
  type        = bool
  default     = false
}