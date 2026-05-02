resource "aws_sqs_queue" "lambda_dlq" {
  name                      = "${var.project_name}-lambda-dlq"
  message_retention_seconds = 1209600

  tags = {
    Project = var.project_name
    Purpose = "lambda-remediation-failure-dlq"
  }
}

resource "aws_sqs_queue" "eventbridge_dlq" {
  name                      = "${var.project_name}-eventbridge-dlq"
  message_retention_seconds = 1209600

  tags = {
    Project = var.project_name
    Purpose = "eventbridge-target-failure-dlq"
  }
}