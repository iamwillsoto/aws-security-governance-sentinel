resource "aws_kms_key" "sentinel" {
  description             = "Customer-managed KMS key for Operation Sentinel security telemetry and audit data."
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableAccountRootPermissions"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudTrailToEncryptLogs"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = [
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]

        Resource = "*"

        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${var.project_name}-trail"
          }

          StringLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/${var.project_name}-trail"
          }
        }
      },
      {
        Sid    = "AllowCloudWatchLogsUseOfKey"
        Effect = "Allow"

        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }

        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]

        Resource = "*"
      },
      {
        Sid    = "AllowSNSToUseKey"
        Effect = "Allow"

        Principal = {
          Service = "sns.amazonaws.com"
        }

        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]

        Resource = "*"
      },
      {
        Sid    = "AllowSQSToUseKey"
        Effect = "Allow"

        Principal = {
          Service = "sqs.amazonaws.com"
        }

        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:DescribeKey"
        ]

        Resource = "*"
      },
      {
        Sid    = "AllowDynamoDBToUseKey"
        Effect = "Allow"

        Principal = {
          Service = "dynamodb.amazonaws.com"
        }

        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]

        Resource = "*"
      }
    ]
  })

  tags = {
    Project = var.project_name
    Purpose = "customer-managed-encryption"
  }
}

resource "aws_kms_alias" "sentinel" {
  name          = "alias/${var.project_name}-security-key"
  target_key_id = aws_kms_key.sentinel.key_id
}