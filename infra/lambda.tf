data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/sentinel_remediator.py"
  output_path = "${path.module}/sentinel_remediator.zip"
}

resource "aws_lambda_function" "remediator" {
  function_name = "${var.project_name}-remediator"
  role          = aws_iam_role.lambda_role.arn
  handler       = "sentinel_remediator.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      AUDIT_TABLE                 = aws_dynamodb_table.audit.name
      SNS_TOPIC_ARN               = aws_sns_topic.alerts.arn
      REMOVE_PUBLIC_BUCKET_POLICY = "true"
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]

  tags = {
    Project = var.project_name
  }
}