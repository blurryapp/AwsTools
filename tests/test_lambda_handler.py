# tests/test_lambda_handler.py
import unittest
import json
# Adjust the import path based on how tests will be run.
# If running 'python -m unittest discover' from the root directory,
# 'from src.lambda_handler import LambdaHandler' should work if src is a package.
from src.lambda_handler import LambdaHandler

class TestLambdaHandler(unittest.TestCase):

    def setUp(self):
        """Set up for test methods."""
        self.handler = LambdaHandler()

    def test_handle_event_empty_event(self):
        """Test handle_event with an empty event."""
        event = {}
        context = {} # Context is often not critical for basic unit tests

        response = self.handler.handle_event(event, context)

        self.assertEqual(response["statusCode"], 200)
        response_body = json.loads(response["body"])
        self.assertEqual(response_body["message"], "Hello from LambdaHandler!")
        self.assertEqual(response_body["received_event"], event)

    def test_handle_event_with_data(self):
        """Test handle_event with some data in the event."""
        event = {"name": "TestUser", "value": 123}
        context = {}

        response = self.handler.handle_event(event, context)

        self.assertEqual(response["statusCode"], 200)
        response_body = json.loads(response["body"])
        self.assertEqual(response_body["message"], "Hello from LambdaHandler!")
        self.assertEqual(response_body["received_event"], event)

    def test_handle_event_response_structure(self):
        """Test that the response structure is as expected."""
        event = {"test": "structure"}
        context = {}

        response = self.handler.handle_event(event, context)

        self.assertIn("statusCode", response)
        self.assertIn("body", response)
        self.assertEqual(response["statusCode"], 200)

        try:
            body_json = json.loads(response["body"])
            self.assertIn("message", body_json)
            self.assertIn("received_event", body_json)
        except json.JSONDecodeError:
            self.fail("Response body is not valid JSON")

if __name__ == '__main__':
    unittest.main()
