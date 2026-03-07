"""
AWS DynamoDB + SNS integration for LifeLink Smart Ambulance System.

This module provides:
  - store_accident()   → writes accident data to DynamoDB
  - publish_alert()    → sends emergency SMS via SNS
  - get_accident()     → retrieves a single accident record
  - update_accident_status() → updates the status field

Requires environment variables:
  AWS_REGION           (default: ap-south-1)
  SNS_TOPIC_ARN        (your ambulance-alerts topic ARN)
  AWS_ACCESS_KEY_ID    (from Learner Lab credentials)
  AWS_SECRET_ACCESS_KEY
  AWS_SESSION_TOKEN    (Learner Lab requires this)
"""

import os
import uuid
import datetime
import boto3
from botocore.exceptions import ClientError

# ---------- Configuration ----------
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN", "arn:aws:sns:us-east-1:098268776029:ambulance-alerts")
DYNAMODB_TABLE = "accidents"

# ---------- AWS Clients ----------
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
sns_client = boto3.client("sns", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)


def store_accident(
    vehicle_id: str,
    latitude: float,
    longitude: float,
    impact_force: float,
    status: str = "detected",
) -> dict:
    """
    Store an accident record in DynamoDB.

    Returns the full item dict including the generated accident_id.
    """
    accident_id = str(uuid.uuid4())
    timestamp = datetime.datetime.utcnow().isoformat() + "Z"

    item = {
        "accident_id": accident_id,
        "vehicle_id": vehicle_id,
        "latitude": str(latitude),
        "longitude": str(longitude),
        "impact_force": str(impact_force),
        "timestamp": timestamp,
        "status": status,
    }

    table.put_item(Item=item)
    return item


def publish_alert(latitude: float, longitude: float, accident_id: str = "") -> str:
    """
    Publish an emergency alert to the SNS topic.

    Returns the SNS MessageId on success.
    """
    if not SNS_TOPIC_ARN:
        raise ValueError("SNS_TOPIC_ARN environment variable is not set")

    message = (
        f"\U0001f691 Accident detected!\n"
        f"Location: {latitude}, {longitude}\n"
        f"Accident ID: {accident_id}\n"
        f"Immediate ambulance dispatch required."
    )

    response = sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=message,
        Subject="LifeLink Emergency Alert",
    )
    return response["MessageId"]


def get_accident(accident_id: str) -> dict | None:
    """Retrieve a single accident record by ID."""
    response = table.get_item(Key={"accident_id": accident_id})
    return response.get("Item")


def update_accident_status(accident_id: str, new_status: str) -> dict:
    """Update the status of an existing accident record."""
    response = table.update_item(
        Key={"accident_id": accident_id},
        UpdateExpression="SET #s = :val, updated_at = :ts",
        ExpressionAttributeNames={"#s": "status"},
        ExpressionAttributeValues={
            ":val": new_status,
            ":ts": datetime.datetime.utcnow().isoformat() + "Z",
        },
        ReturnValues="ALL_NEW",
    )
    return response["Attributes"]
