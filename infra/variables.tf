variable "aws_region" {
  description = "AWS region for Operation Sentinel resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "operation-sentinel"
}

variable "alert_phone_number" {
  description = "Phone number subscribed to security alerts in E.164 format, such as +14015551234."
  type        = string
}