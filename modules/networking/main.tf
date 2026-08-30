# Get the available Availability Zones in the current AWS region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "COB"
  }
}

# standard COB VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-vpc"
    }
  )
}

# public subnets across two availability zones
resource "aws_subnet" "public" {
  count = 2

  vpc_id = aws_vpc.this.id

  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    count.index
  )

  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-public-${count.index + 1}"
      Tier = "public"
    }
  )
}

# private subnets across two availability zones
resource "aws_subnet" "private" {
  count = 2

  vpc_id = aws_vpc.this.id

  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    count.index + 10
  )

  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-private-${count.index + 1}"
      Tier = "private"
    }
  )
}

# this allows public subnets to communicate with the internet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-igw"
    }
  )
}

# routing table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-public-rt"
    }
  )
}

# connect the public subnets to the public routing table
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# create an elastic IP only when NAT is requested
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-nat-eip"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# optional NAT Gateway for outbound access from private subnets
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-nat"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# routing table used by private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[0].id
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-private-rt"
    }
  )
}

# connect private subnets to their routing table
resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}