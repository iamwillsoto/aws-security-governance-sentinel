resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-remediator"
  retention_in_days = 30

  tags = {
    Project = var.project_name
  }
}

resource "aws_cloudwatch_dashboard" "sentinel" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "log"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          query  = "SOURCE '${aws_cloudwatch_log_group.lambda_logs.name}' | fields @timestamp, @message | sort @timestamp desc | limit 20"
          region = var.aws_region
          title  = "Operation Sentinel Remediation Logs"
          view   = "table"
        }
      }
    ]
  })
}