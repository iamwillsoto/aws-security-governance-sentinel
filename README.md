# Operation Sentinel: AWS Security Governance Platform

An event-driven security automation platform that detects risky S3 public access changes and remediates them in seconds — without human intervention.

---

## Problem

Cloud environments move faster than manual security review. A single `DeleteBucketPublicAccessBlock` call can expose sensitive data before a human notices. For regulated financial environments, delayed remediation is a compliance failure, not just an operational one.

## Solution

Operation Sentinel closes that gap with a fully automated control loop: detect → remediate → audit → alert → validate. Every remediation is logged, structured, and traceable. The infrastructure itself is versioned, hardened, and policy-scanned before deployment.

---

## Architecture

```text
Risky S3 API call
→ CloudTrail (event capture)
→ EventBridge (pattern match)
→ Lambda (automated remediation)
→ S3 Block Public Access restored
→ DynamoDB (structured audit record)
→ SNS SMS alert
→ CloudWatch (operational visibility)
```

---

## Stack

| Layer | Service |
|---|---|
| Detection | AWS CloudTrail, Amazon EventBridge |
| Remediation | AWS Lambda (Python) |
| Audit | Amazon DynamoDB |
| Alerting | Amazon SNS SMS |
| Observability | Amazon CloudWatch Logs + Dashboard |
| Resilience | Amazon SQS DLQs, EventBridge retry policy, CloudWatch alarms |
| Governance | Terraform, GitHub Actions, Trivy, OPA/Rego policy examples |

---

## Detection

CloudTrail captures management-plane API activity. EventBridge matches security-relevant S3 events:

- `DeleteBucketPublicAccessBlock` *(primary validated trigger)*
- Bucket policy modifications
- ACL changes

CloudTrail log file validation is enabled to support audit integrity and tamper detection for the underlying log stream.

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

The function also includes a self-trigger guardrail to prevent remediation loops if future event patterns are broadened.

---

## Observability

- **CloudWatch Logs** — structured execution output per remediation event
- **DynamoDB** — durable audit records with event ID, timestamp, bucket name, event name, and remediation outcome
- **SNS SMS** — immediate security notification on remediation trigger
- **CloudWatch Dashboard** — centralized visibility into remediation activity
- **CloudWatch Alarms** — alerting for Lambda errors, Lambda throttles, and DLQ activity

---

## Resilience

Operation Sentinel includes failure-handling controls so remediation events are not silently lost.

- Lambda asynchronous failure destination routes failed remediation events to an SQS DLQ
- EventBridge target includes retry behavior and a dedicated SQS DLQ
- SQS DLQs use server-side encryption
- DynamoDB point-in-time recovery protects remediation audit records
- Account-level S3 Block Public Access provides a preventive guardrail beyond the monitored bucket

---

## Governance

The full platform is defined in Terraform. The GitHub Actions CI/CD pipeline validates the infrastructure code through:

1. `terraform fmt` — format validation
2. `terraform init` + `terraform validate` — configuration integrity
3. `trivy` — infrastructure-as-code security scan configured through `policies/trivy.yaml`

The repository also includes OPA/Rego policy examples in `policies/opa/terraform-security.rego` to document governance intent for S3 public access and CloudWatch retention controls.

Trivy is the active scanner in the current CI workflow. The Rego policies are structured for future Conftest integration.

---

## Validation

Validated by intentionally invoking `DeleteBucketPublicAccessBlock` on the monitored bucket.

**Result:**

```text
remediation_status = success
```

EventBridge matched the CloudTrail event, Lambda restored all four Block Public Access settings, DynamoDB recorded the structured audit entry, SNS delivered the SMS notification, and CloudWatch displayed the remediation activity.

Post-hardening validation confirmed that the platform continued to remediate successfully after adding audit integrity, failure handling, encrypted alerting, account-level S3 guardrails, and operational alarms.

---

## Security Design Principles

- Event-driven detection — no polling, no cron
- Automated remediation — zero human dependency for known violations
- Least-privilege IAM — scoped per action, not per service
- Structured audit evidence — DynamoDB records survive log retention windows
- Audit integrity — CloudTrail log file validation enabled
- Preventive guardrails — account-level S3 Block Public Access
- Failure handling — Lambda and EventBridge DLQs
- Encrypted messaging — SNS and SQS encryption enabled
- Operational monitoring — CloudWatch alarms for remediation health
- IaC-only infrastructure — no manual console provisioning
- CI/CD policy gates — Trivy scans before infrastructure promotion

---

## Scope and Limitations

This implementation targets a single AWS account and one monitored S3 bucket. It is intentionally scoped as a focused, demonstrable security control — not a full organizational rollout.

Production expansion paths include AWS Config custom rules, Security Hub integration, IAM privilege escalation detection, multi-account deployment via AWS Organizations, centralized log archive accounts, and organization-level SCP guardrails.

This implementation uses AWS-managed encryption for SNS, SQS-managed encryption for DLQs, and SSE-S3 for S3 buckets. Customer-managed KMS keys are identified as a production hardening enhancement and are tracked through Trivy policy exceptions.

Lambda reserved concurrency was evaluated as a runtime safety control but was not enabled due to account-level concurrency quota constraints. It remains a recommended production enhancement after quota validation or increase.

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
│   ├── sqs.tf
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
├── .trivyignore
└── README.md
```

---

## Project Outcome

Operation Sentinel demonstrates a hardened AWS security governance pattern using native cloud services and Infrastructure as Code.

The project validates practical experience with:

- CloudTrail-based security event detection
- EventBridge-driven automation
- Lambda-based remediation
- S3 public access governance
- IAM least privilege
- DynamoDB audit logging and point-in-time recovery
- SNS SMS alerting
- SQS dead-letter queues
- CloudWatch observability and alarms
- Terraform infrastructure deployment
- GitHub Actions CI validation
- Trivy IaC scanning
- OPA/Rego policy-as-code structure
