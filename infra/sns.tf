resource "aws_sns_topic" "alerts" {
  name              = "${var.project_name}-security-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = {
    Project = var.project_name
  }
}

resource "aws_sns_topic_subscription" "sms" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "sms"
  endpoint  = var.alert_phone_number
}