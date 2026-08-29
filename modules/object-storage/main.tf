# The AWS account ID has to be gotten and added in the bucket name because each s3 bucket name must be globally unique and this helps achieve that
data "aws_caller_identity" "current" {}

locals {
  bucket_name = lower(
    "${var.project}-${var.environment}-${data.aws_caller_identity.current.account_id}-storage"
  )

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "COB"
  }
}

# the S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = local.common_tags
}

# this prevents the bucket from becoming publicly accessible
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# this explicitly enforces encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# versioning is enabled by default but can be controlled by the consumer
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# this cleans up old object versions and unfinished uploads
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  depends_on = [aws_s3_bucket_versioning.this]

  rule {
    id     = "cob-storage-lifecycle"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}