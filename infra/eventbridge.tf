resource "aws_cloudwatch_event_rule" "s3_public_risk" {
  name        = "${var.project_name}-s3-public-risk"
  description = "Detects risky S3 public access and bucket policy changes."

  event_pattern = jsonencode({
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName = [
        "DeleteBucketPublicAccessBlock",
        "PutBucketPolicy",
        "PutBucketAcl"
      ]
    }
  })

  tags = {
    Project = var.project_name
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.s3_public_risk.name
  target_id = "SendToSentinelRemediator"
  arn       = aws_lambda_function.remediator.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remediator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_public_risk.arn
}