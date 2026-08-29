variable "project" {
  description = "Name of the example application."
  type        = string
  default     = "analytics-demo"
}

variable "environment" {
  description = "Environment to deploy."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC."
  type        = string
  default     = "10.0.0.0/16"
}

#variable "ami_id" {
#  description = "AMI ID used by the EC2 example."
#  type        = string
#}

variable "container_image" {
  description = "Container image used by the ECS example."
  type        = string
  default     = "nginx:latest"
}