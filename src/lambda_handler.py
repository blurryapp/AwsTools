# src/lambda_handler.py
import json

class LambdaHandler:
    def __init__(self):
        pass

    def handle_event(self, event, context):
        # Simple example: echo back the input event
        print(f"Received event: {event}")
        response = {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Hello from LambdaHandler!",
                "received_event": event
            })
        }
        return response

# This is a common pattern for AWS Lambda in Python
# The global handler function that AWS Lambda will call
def lambda_handler(event, context):
    handler = LambdaHandler()
    return handler.handle_event(event, context)
