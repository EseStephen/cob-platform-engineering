locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "COB"
  }
}

# this places the database in COB private subnets
resource "aws_db_subnet_group" "this" {
  name = "${var.project}-${var.environment}-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-db-subnet-group"
    }
  )
}

# Security boundary for the database
resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-rds-sg"
  description = "COB security group for RDS"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-rds-sg"
    }
  )
}

# only the approved application security group can access PostgreSQL
resource "aws_vpc_security_group_ingress_rule" "postgres" {
  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.allowed_security_group_id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

# allow outbound traffic from the database
resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# PostgreSQL database
resource "aws_db_instance" "this" {
  identifier = "${var.project}-${var.environment}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version

  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100

  db_name  = var.database_name
  username = var.master_username

  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  publicly_accessible = false

  multi_az = var.multi_az

  storage_encrypted = true

  backup_retention_period = var.backup_retention_period

  deletion_protection = false
  skip_final_snapshot = true

  auto_minor_version_upgrade = true

  tags = local.common_tags
}