resource "aws_sqs_queue" "lambda_dlq" {
  name                      = "${var.project_name}-lambda-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true

  tags = {
    Project = var.project_name
    Purpose = "lambda-remediation-failure-dlq"
  }
}

resource "aws_sqs_queue" "eventbridge_dlq" {
  name                      = "${var.project_name}-eventbridge-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true

  tags = {
    Project = var.project_name
    Purpose = "eventbridge-target-failure-dlq"
  }
}

resource "aws_sqs_queue_policy" "eventbridge_dlq_policy" {
  queue_url = aws_sqs_queue.eventbridge_dlq.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgeToSendMessages"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.eventbridge_dlq.arn
      }
    ]
  })
}