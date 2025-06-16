#!/bin/bash

# Script to deploy the Lambda function to LocalStack

AWS_REGION="us-east-1"
LAMBDA_FUNCTION_NAME="my-lambda-function"
LAMBDA_HANDLER="src.lambda_handler.lambda_handler" # Format: <directory_with_handler_file_relative_to_zip_root>.<filename_without_py>.<handler_function_name>
LAMBDA_ROLE_NAME="lambda-ex"
LAMBDA_RUNTIME="python3.9"
ZIP_FILE="lambda_package.zip"
SOURCE_DIR="src"

# LocalStack Lambda endpoint
AWS_ENDPOINT_URL="http://localhost:4566"

echo "Configuring AWS CLI for LocalStack..."
aws configure set aws_access_key_id test --profile localstack
aws configure set aws_secret_access_key test --profile localstack
aws configure set default.region ${AWS_REGION} --profile localstack

echo "Creating Lambda deployment package..."
# Remove old zip file if it exists
rm -f ${ZIP_FILE}

# Create a new zip file
# Go into the src directory to zip its contents
# This ensures that lambda_handler.py is at the root of the zip
cd ${SOURCE_DIR}
zip -r ../${ZIP_FILE} .
cd .. # Go back to the project root

echo "Checking for IAM role ${LAMBDA_ROLE_NAME}..."
ROLE_ARN=$(aws iam get-role --role-name ${LAMBDA_ROLE_NAME} --endpoint-url=${AWS_ENDPOINT_URL} --profile localstack --query "Role.Arn" --output text 2>/dev/null)

if [ -z "$ROLE_ARN" ]; then
    echo "IAM role ${LAMBDA_ROLE_NAME} not found. Creating it..."
    ASSUME_ROLE_POLICY_DOCUMENT='{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "lambda.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }]
    }'
    ROLE_ARN=$(aws iam create-role         --role-name ${LAMBDA_ROLE_NAME}         --assume-role-policy-document "${ASSUME_ROLE_POLICY_DOCUMENT}"         --endpoint-url=${AWS_ENDPOINT_URL}         --profile localstack         --query "Role.Arn" --output text)

    if [ -z "$ROLE_ARN" ]; then
        echo "Failed to create IAM role. Exiting."
        exit 1
    fi
    echo "IAM role ${LAMBDA_ROLE_NAME} created with ARN: ${ROLE_ARN}"
else
    echo "IAM role ${LAMBDA_ROLE_NAME} already exists with ARN: ${ROLE_ARN}"
fi

echo "Checking for existing Lambda function ${LAMBDA_FUNCTION_NAME}..."
aws lambda get-function --function-name ${LAMBDA_FUNCTION_NAME} --endpoint-url=${AWS_ENDPOINT_URL} --profile localstack > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Lambda function ${LAMBDA_FUNCTION_NAME} already exists. Updating function code..."
    aws lambda update-function-code         --function-name ${LAMBDA_FUNCTION_NAME}         --zip-file fileb://${ZIP_FILE}         --endpoint-url=${AWS_ENDPOINT_URL}         --profile localstack

    if [ $? -ne 0 ]; then
        echo "Failed to update Lambda function code. Exiting."
        # rm ${ZIP_FILE} # Clean up zip
        exit 1
    fi
    echo "Lambda function code updated."
else
    echo "Lambda function ${LAMBDA_FUNCTION_NAME} not found. Creating new function..."
    aws lambda create-function         --function-name ${LAMBDA_FUNCTION_NAME}         --runtime ${LAMBDA_RUNTIME}         --role ${ROLE_ARN}         --handler ${LAMBDA_HANDLER}         --zip-file fileb://${ZIP_FILE}         --endpoint-url=${AWS_ENDPOINT_URL}         --profile localstack

    if [ $? -ne 0 ]; then
        echo "Failed to create Lambda function. Exiting."
        # rm ${ZIP_FILE} # Clean up zip
        exit 1
    fi
    echo "Lambda function ${LAMBDA_FUNCTION_NAME} created."
fi

echo "Cleaning up deployment package..."
# rm ${ZIP_FILE}

echo "Deployment to LocalStack complete."
echo "You can invoke the function using:"
echo "aws lambda invoke --function-name ${LAMBDA_FUNCTION_NAME} --payload '{\"name\": \"Test\"}' --cli-binary-format raw-in-base64-out --endpoint-url=${AWS_ENDPOINT_URL} --profile localstack output.json && cat output.json"
