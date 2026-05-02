# Operation Sentinel: Event-Driven AWS Security Governance Platform

## Executive Summary

Operation Sentinel is a cloud-native AWS security governance platform that detects risky S3 configuration changes, automatically restores public access protections, records structured audit evidence, and validates infrastructure through security-focused CI/CD controls.

The project demonstrates how native AWS services can be used to build a self-healing security control that reduces manual response dependency, improves audit readiness, and enforces cloud storage governance through Infrastructure as Code.

## Business Use Case

Organizations operating in fast-moving cloud environments cannot rely only on manual reviews to identify every misconfigured resource. Public storage exposure, delayed incident response, and inconsistent infrastructure deployment create operational, financial, and regulatory risk.

Operation Sentinel addresses that problem by creating an automated security control loop:

1. Detect risky S3 public access configuration changes.
2. Trigger an automated remediation workflow.
3. Restore S3 Block Public Access settings.
4. Notify the security team.
5. Record structured audit evidence.
6. Provide dashboard visibility.
7. Validate the infrastructure code through CI/CD security scanning.

This design is especially relevant for businesses operating in regulated or security-sensitive environments where cloud misconfigurations can create material risk.

## Architecture Overview

Operation Sentinel uses CloudTrail, EventBridge, Lambda, S3, DynamoDB, SNS, CloudWatch, Terraform, GitHub Actions, and Trivy.

![Operation Sentinel Architecture](architecture/operation-sentinel-architecture.png)

## Core Services

| Service | Purpose |
|---|---|
| Amazon S3 | Monitored storage resource and CloudTrail log destination |
| AWS CloudTrail | Captures AWS API activity for security-relevant events |
| Amazon EventBridge | Detects risky S3 configuration changes from CloudTrail events |
| AWS Lambda | Performs automated remediation |
| Amazon DynamoDB | Stores structured remediation audit records |
| Amazon SNS | Sends security notifications |
| Amazon CloudWatch | Provides logs and dashboard visibility |
| AWS IAM | Enforces least-privilege access for the remediation function |
| Terraform | Defines the full environment as Infrastructure as Code |
| GitHub Actions | Runs CI/CD validation |
| Trivy | Performs IaC misconfiguration scanning |

## Detection Layer

CloudTrail records AWS management-plane API activity. EventBridge evaluates those events and matches security-relevant S3 actions.

The main validation event for this project is:

```text
DeleteBucketPublicAccessBlock