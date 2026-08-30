locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "COB"
  }

  cluster_name = "${var.project}-${var.environment}-ecs"
  service_name = "${var.project}-${var.environment}-service"
}

# teh ecs cluster
resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

# cloudWatch log group for container logs
resource "aws_cloudwatch_log_group" "this" {
  name              = "/cob/ecs/${var.project}/${var.environment}"
  retention_in_days = 7

  tags = local.common_tags
}

# iam role used by ECS or Fargate to pull images and write the logs
data "aws_iam_policy_document" "execution_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.project}-${var.environment}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role = aws_iam_role.execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# security group for the ecs service
resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-ecs-sg"
  description = "COB security group for ECS service"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-ecs-sg"
    }
  )
}

# only create ingress rules that the consumer explicitly requests
resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = toset(var.allowed_ingress_cidr)

  security_group_id = aws_security_group.this.id

  cidr_ipv4   = each.value
  from_port   = var.container_port
  to_port     = var.container_port
  ip_protocol = "tcp"
}

# allow outbound traffic required by the workload
resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# fargate task definition
resource "aws_ecs_task_definition" "this" {
  family = "${var.project}-${var.environment}-task"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.cpu
  memory = var.memory

  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.project}-container"
      image     = var.container_image
      essential = true

      cpu    = var.cpu
      memory = var.memory

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.execution
  ]
}

data "aws_region" "current" {}

# ecs service
resource "aws_ecs_service" "this" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn

  launch_type   = "FARGATE"
  desired_count = var.desired_count

  network_configuration {
    subnets = var.subnet_ids

    security_groups = [
      aws_security_group.this.id
    ]

    # this ensures COB workloads use private subnets by default
    assign_public_ip = false
  }

  tags = local.common_tags
}