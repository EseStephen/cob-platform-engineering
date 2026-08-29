provider "aws" {
  profile = "nuke-admin"
  region  = "eu-north-1"
}

module "networking" {
  source = "../../modules/networking"

  project     = var.project
  environment = var.environment

  vpc_cidr = var.vpc_cidr

  enable_nat_gateway = true
}

module "storage" {
  source = "../../modules/object-storage"

  project     = var.project
  environment = var.environment

  versioning_enabled = true
}

module "data_platform" {
  source = "../../modules/data-platform"

  project     = var.project
  environment = var.environment

  s3_bucket_name = module.storage.bucket_name

  athena_query_results_bucket = module.storage.bucket_name
}

module "application_identity" {
  source = "../../modules/identity"

  project     = var.project
  environment = var.environment

  workload_name = "analytics-app"

  trusted_service = "ecs-tasks.amazonaws.com"

  allowed_actions = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket"
  ]

  allowed_resource_arns = [
    module.storage.bucket_arn,
    "${module.storage.bucket_arn}/*"
  ]
}

module "application" {
  source = "../../modules/compute/ecs"

  project     = var.project
  environment = var.environment

  vpc_id = module.networking.vpc_id

  subnet_ids = module.networking.private_subnet_ids

  container_image = var.container_image

  container_port = 80

  cpu    = 256
  memory = 512

  desired_count = 1

  task_role_arn = module.application_identity.role_arn
}

module "database" {
  source = "../../modules/database/rds"

  project     = var.project
  environment = var.environment

  vpc_id = module.networking.vpc_id

  private_subnet_ids = module.networking.private_subnet_ids

  allowed_security_group_id = module.application.security_group_id

  database_name = "analytics"

  instance_class = "db.t4g.micro"

  multi_az = false

  backup_retention_period = 7
}
