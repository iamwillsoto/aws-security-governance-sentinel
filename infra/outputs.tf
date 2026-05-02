output "monitored_bucket_name" {
  value = aws_s3_bucket.monitored.bucket
}

output "cloudtrail_name" {
  value = aws_cloudtrail.sentinel.name
}

output "lambda_function_name" {
  value = aws_lambda_function.remediator.function_name
}

output "audit_table_name" {
  value = aws_dynamodb_table.audit.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.sentinel.dashboard_name
}