locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "COB"
  }

  role_name = "${var.project}-${var.environment}-${var.workload_name}-role"
}

# this defines which AWS service is allowed to assume this role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        var.trusted_service
      ]
    }
  }
}

# this creates the least-privilege permissions requested by the workload
data "aws_iam_policy_document" "permissions" {
  statement {
    effect = "Allow"

    actions   = var.allowed_actions
    resources = var.allowed_resource_arns
  }
}

# IAM role used by the workload
resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = local.common_tags
}

# Customer-managed policy containing the workload permissions
resource "aws_iam_policy" "this" {
  name        = "${var.project}-${var.environment}-${var.workload_name}-policy"
  description = "COB-managed policy for ${var.workload_name}"

  policy = data.aws_iam_policy_document.permissions.json

  tags = local.common_tags
}

# Attach the managed policy to the workload role
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# the ec2 requires an instance profile to use an IAM role
resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = "${var.project}-${var.environment}-${var.workload_name}-profile"
  role = aws_iam_role.this.name

  tags = local.common_tags
}