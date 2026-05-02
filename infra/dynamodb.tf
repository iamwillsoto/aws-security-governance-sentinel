resource "aws_dynamodb_table" "audit" {
  name         = "${var.project_name}-audit-log"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Project = var.project_name
    Purpose = "remediation-audit"
  }
}