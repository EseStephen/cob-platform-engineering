output "role_name" {
  description = "Name of the IAM role created by COB."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of the IAM role created by COB."
  value       = aws_iam_role.this.arn
}

output "policy_arn" {
  description = "ARN of the workload IAM policy."
  value       = aws_iam_policy.this.arn
}

output "instance_profile_name" {
  description = "EC2 instance profile name, if one was created."

  value = (
    var.create_instance_profile
    ? aws_iam_instance_profile.this[0].name
    : null
  )
}