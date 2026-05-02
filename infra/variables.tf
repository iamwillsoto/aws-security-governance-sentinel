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

variable "alert_email" {
  description = "Email address subscribed to security alerts."
  type        = string
}