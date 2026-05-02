resource "aws_s3_bucket" "monitored" {
  bucket_prefix = "${var.project_name}-monitored-"

  tags = {
    Project     = var.project_name
    Environment = "security-lab"
    Purpose     = "monitored-resource"
  }
}

resource "aws_s3_bucket_public_access_block" "monitored" {
  bucket = aws_s3_bucket.monitored.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "monitored" {
  bucket = aws_s3_bucket.monitored.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "monitored" {
  bucket = aws_s3_bucket.monitored.id

  versioning_configuration {
    status = "Enabled"
  }
}