variable "project" {
  description = "name of the project or application."
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
  description = "ID of the VPC where the EC2 instance will run."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance will run."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance."
  type        = string
}

variable "allowed_ingress_cidr" {
  description = "CIDR block allowed to access the workload."
  type        = list(string)
  default     = []
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to the EC2 instance."
  type        = string
  default     = null
}