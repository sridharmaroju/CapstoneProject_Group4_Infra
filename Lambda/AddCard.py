import json
import boto3
import os

table_name = os.environ.get("CARDS_TABLE")
if not table_name:
    raise ValueError("Environment variable CARDS_TABLE is not set")

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    # Get card_number from path parameters
    card_number = event["pathParameters"]["cardId"]

    # Get JSON body
    body = json.loads(event["body"])
    user_id = body["UserId"]
    balance = body["Balance"]

    # Insert into DynamoDB
    table.put_item(
        Item={
            "CARD_NUMBER": card_number,
            "USER_ID": user_id,
            "BALANCE": balance
        }
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Card added successfully",
            "card_number": card_number,
            "balance": balance
        })
    }
