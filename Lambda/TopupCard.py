import json
import boto3
import os
from decimal import Decimal

table_name = os.environ.get("CARDS_TABLE")
if not table_name:
    raise ValueError("Environment variable CARDS_TABLE is not set")

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Extract cardId from path parameters
        card_number = event['pathParameters']['cardId']
        
        # Parse JSON payload
        body = json.loads(event['body'])
        topup_amount = body.get('amount')
        if topup_amount is None:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Missing 'amount' in request body"})
            }
        
        # Update DynamoDB balance atomically
        response = table.update_item(
            Key={"CARD_NUMBER": card_number},
            UpdateExpression="SET BALANCE = if_not_exists(BALANCE, :zero) + :topup",
            ExpressionAttributeValues={
                ":topup": Decimal(str(topup_amount)),
                ":zero": Decimal(0)
            },
            ReturnValues="UPDATED_NEW"
        )

        new_balance = float(response['Attributes']['BALANCE'])

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": f"Card {card_id} topped up successfully",
                "new_balance": new_balance
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": f"Error: {str(e)}"})
        }
