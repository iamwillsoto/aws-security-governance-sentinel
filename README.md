# Operation Sentinel: AWS Security Governance Platform

An event-driven security automation platform that detects risky S3 public access changes and remediates them in seconds — without human intervention.

---

## Problem

Cloud environments move faster than manual security review. A single `DeleteBucketPublicAccessBlock` call can expose sensitive data for hours before a human notices. For regulated financial environments, delayed remediation is a compliance failure, not just an operational one.

## Solution

Operation Sentinel closes that gap with a fully automated control loop: detect → remediate → audit → alert. Every remediation is logged, structured, and traceable. The infrastructure itself is versioned and policy-scanned before deployment.

---

## Architecture

Risky S3 API call
→ CloudTrail (event capture)
→ EventBridge (pattern match)
→ Lambda (automated remediation)
→ S3 Block Public Access restored
→ DynamoDB (structured audit record)
→ SNS (security alert)
→ CloudWatch (operational visibility)

---

## Stack

| Layer | Service |
|---|---|
| Detection | AWS CloudTrail, Amazon EventBridge |
| Remediation | AWS Lambda (Python) |
| Audit | Amazon DynamoDB |
| Alerting | Amazon SNS |
| Observability | Amazon CloudWatch Logs + Dashboard |
| Governance | Terraform, GitHub Actions, Trivy |

---

## Detection

CloudTrail captures all management-plane API activity. EventBridge matches the following security-relevant S3 events:

- `DeleteBucketPublicAccessBlock` *(primary validated trigger)*
- Bucket policy modifications
- ACL changes

---

## Remediation

The Lambda responder extracts the affected bucket from the CloudTrail event and reapplies all four Block Public Access controls:

```python
BlockPublicAcls       = True
IgnorePublicAcls      = True
BlockPublicPolicy     = True
RestrictPublicBuckets = True
```

The execution role is scoped to least privilege — only the permissions required to remediate the monitored bucket, write audit records, publish alerts, and log execution.

---

## Observability

- **CloudWatch Logs** — structured execution output per remediation event
- **DynamoDB** — durable audit records with event ID, timestamp, bucket name, event name, and remediation outcome
- **SNS** — immediate security alert on remediation trigger
- **CloudWatch Dashboard** — centralized visibility into remediation frequency and status

---

## Governance

The full platform is defined in Terraform. The GitHub Actions CI/CD pipeline enforces:

1. `terraform fmt` — format validation
2. `terraform init` + `terraform validate` — configuration integrity
3. `trivy` — infrastructure-as-code security scan

No infrastructure ships without passing all three gates.

---

## Validation

Validated by intentionally invoking `DeleteBucketPublicAccessBlock` on the monitored bucket.

**Result:**

remediation_status = success

EventBridge matched the CloudTrail event, Lambda restored all four Block Public Access settings within seconds, DynamoDB recorded the structured audit entry, and SNS delivered the security notification.

---

## Security Design Principles

- Event-driven detection — no polling, no cron
- Automated remediation — zero human dependency for known violations
- Least-privilege IAM — scoped per action, not per service
- Structured audit evidence — DynamoDB records survive log retention windows
- IaC-only infrastructure — no manual console provisioning
- CI/CD policy gates — Trivy scans before any deployment

---

## Scope and Limitations

This implementation targets a single AWS account and one monitored S3 bucket. It is intentionally scoped as a focused, demonstrable security control — not a full organizational rollout.

Production expansion paths include AWS Config custom rules, Security Hub integration, IAM privilege escalation detection, multi-account deployment via AWS Organizations, and organization-level SCP guardrails.

---

## Repository Structure

```text
aws-security-governance-sentinel/
├── .github/
│   └── workflows/
│       └── security-iac.yaml
├── architecture/
├── infra/
│   ├── cloudtrail.tf
│   ├── cloudwatch.tf
│   ├── dynamodb.tf
│   ├── eventbridge.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── s3.tf
│   ├── sns.tf
│   ├── terraform.tfvars.example
│   └── variables.tf
├── lambda/
│   ├── requirements.txt
│   └── sentinel_remediator.py
├── policies/
│   ├── opa/
│   │   └── terraform-security.rego
│   └── trivy.yaml
├── validation-screenshots/
├── .gitignore
└── README.md
```