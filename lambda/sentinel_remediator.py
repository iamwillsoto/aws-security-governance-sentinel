import json
import os
import uuid
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError

s3 = boto3.client("s3")
sns = boto3.client("sns")
dynamodb = boto3.resource("dynamodb")

AUDIT_TABLE = os.environ["AUDIT_TABLE"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
REMOVE_PUBLIC_BUCKET_POLICY = os.environ.get("REMOVE_PUBLIC_BUCKET_POLICY", "false").lower() == "true"

table = dynamodb.Table(AUDIT_TABLE)


def lambda_handler(event, context):
    event_id = str(uuid.uuid4())
    event_time = datetime.now(timezone.utc).isoformat()

    detail = event.get("detail", {})
    event_name = detail.get("eventName", "Unknown")
    user_identity = detail.get("userIdentity", {})
    request_params = detail.get("requestParameters", {})

    bucket_name = (
        request_params.get("bucketName")
        or request_params.get("bucket")
        or request_params.get("name")
    )

    result = {
        "event_id": event_id,
        "event_time": event_time,
        "event_name": event_name,
        "bucket_name": bucket_name or "unknown",
        "remediation_status": "started",
        "principal": json.dumps(user_identity, default=str),
    }

    try:
        if not bucket_name:
            raise ValueError("Bucket name could not be extracted from event payload.")

        s3.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                "BlockPublicAcls": True,
                "IgnorePublicAcls": True,
                "BlockPublicPolicy": True,
                "RestrictPublicBuckets": True,
            },
        )

        policy_removed = False

        if REMOVE_PUBLIC_BUCKET_POLICY and event_name == "PutBucketPolicy":
            try:
                s3.delete_bucket_policy(Bucket=bucket_name)
                policy_removed = True
            except ClientError as delete_error:
                print(f"Bucket policy delete skipped or failed: {delete_error}")

        result["remediation_status"] = "success"
        result["policy_removed"] = str(policy_removed)
        result["message"] = f"Public access controls restored for bucket {bucket_name}."

    except Exception as error:
        result["remediation_status"] = "failed"
        result["error"] = str(error)

    table.put_item(Item=result)

    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=f"Operation Sentinel: {result['remediation_status'].upper()}",
        Message=json.dumps(result, indent=2),
    )

    print(json.dumps(result))

    return {
        "statusCode": 200,
        "body": json.dumps(result),
    }