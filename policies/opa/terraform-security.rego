package terraform.security

# Operation Sentinel OPA policy examples.
# These policies document governance intent for Terraform-managed cloud resources.
# Trivy is the active scanner in CI for this project; this file demonstrates how
# additional policy-as-code controls could be extended with OPA/Rego.

deny[msg] {
  resource := input.resource.aws_s3_bucket_public_access_block[_]
  not resource.config.block_public_acls
  msg := sprintf("S3 public access block must enable block_public_acls for resource %s", [resource.name])
}

deny[msg] {
  resource := input.resource.aws_s3_bucket_public_access_block[_]
  not resource.config.block_public_policy
  msg := sprintf("S3 public access block must enable block_public_policy for resource %s", [resource.name])
}

deny[msg] {
  resource := input.resource.aws_s3_bucket_public_access_block[_]
  not resource.config.ignore_public_acls
  msg := sprintf("S3 public access block must enable ignore_public_acls for resource %s", [resource.name])
}

deny[msg] {
  resource := input.resource.aws_s3_bucket_public_access_block[_]
  not resource.config.restrict_public_buckets
  msg := sprintf("S3 public access block must enable restrict_public_buckets for resource %s", [resource.name])
}

deny[msg] {
  resource := input.resource.aws_cloudwatch_log_group[_]
  not resource.config.retention_in_days
  msg := sprintf("CloudWatch log groups must define retention_in_days for resource %s", [resource.name])
}