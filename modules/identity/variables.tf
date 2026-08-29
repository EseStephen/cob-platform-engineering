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

variable "workload_name" {
  description = "Name of the workload that will use the IAM role."
  type        = string
}

variable "trusted_service" {
  description = "AWS service allowed to assume this role."
  type        = string

  validation {
    condition = contains([
      "ec2.amazonaws.com",
      "ecs-tasks.amazonaws.com",
      "glue.amazonaws.com"
    ], var.trusted_service)

    error_message = "Trusted service must be EC2, ECS tasks, or Glue."
  }
}

variable "allowed_actions" {
  description = "Specific AWS actions the workload is allowed to perform."
  type        = list(string)

  validation {
    condition = (
      length(var.allowed_actions) > 0 &&
      alltrue([
        for action in var.allowed_actions :
        !can(regex("\\*", action))
      ])
    )

    error_message = "At least one specific action is required and wildcard actions are not allowed."
  }
}

variable "allowed_resource_arns" {
  description = "AWS resource ARNs the workload can access."
  type        = list(string)

  validation {
    condition = (
      length(var.allowed_resource_arns) > 0 &&
      alltrue([
        for arn in var.allowed_resource_arns :
        arn != "*"
      ])
    )

    error_message = "Resources must be explicitly scoped; a standalone * is not allowed."
  }
}

variable "create_instance_profile" {
  description = "Create an instance profile when the role will be used by EC2."
  type        = bool
  default     = false
}