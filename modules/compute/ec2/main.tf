locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "COB"
  }
}

# Security group for the EC2 workload
resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-ec2-sg"
  description = "COB security group for EC2 workload"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-ec2-sg"
    }
  )
}

# Only create ingress rules when the consumer explicitly provides them
resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = toset(var.allowed_ingress_cidr)

  security_group_id = aws_security_group.this.id

  cidr_ipv4   = each.value
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# Allow outbound traffic
resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# EC2 workload
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  iam_instance_profile = var.iam_instance_profile

  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-ec2"
    }
  )
}