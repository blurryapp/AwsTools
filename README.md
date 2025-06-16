# AWS Lambda OOP Project with LocalStack

This project provides a basic structure for developing AWS Lambda functions using an Object-Oriented Programming (OOP) approach and testing them locally with LocalStack.

## Project Structure

```
.
├── Dockerfile              # Defines the container for the Lambda function
├── docker-compose.yml      # Configures LocalStack and the app environment
├── requirements.txt        # Python dependencies
├── README.md               # This file
├── src                     # Source code for the Lambda function
│   ├── __init__.py
│   └── lambda_handler.py   # Main Lambda handler logic
├── tests                   # Unit tests
│   ├── __init__.py
│   └── test_lambda_handler.py
└── scripts                 # Helper scripts (e.g., for deployment)
    └── deploy_local.sh     # Example script to deploy to LocalStack
```

## Prerequisites

*   Docker: [Install Docker](https://docs.docker.com/get-docker/)
*   Docker Compose: Usually comes with Docker Desktop. If not, [install Docker Compose](https://docs.docker.com/compose/install/).
*   AWS CLI: [Install AWS CLI](https://aws.amazon.com/cli/) (configured for LocalStack interaction).

## Setup and Local Development

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd <repository_name>
    ```

2.  **Start LocalStack:**
    This will start LocalStack with Lambda, S3, IAM, STS and API Gateway services enabled.
    ```bash
    docker-compose up -d localstack
    ```
    You can check the logs using `docker-compose logs localstack`.

3.  **Build the Lambda Docker image:**
    The `docker-compose.yml` also defines an `app` service that can be used to build your Lambda image.
    ```bash
    docker-compose build app
    ```
    Alternatively, you can build directly using Docker:
    ```bash
    docker build -t my-lambda-app .
    ```

## Running Unit Tests

To run the unit tests:

1.  Ensure you are in the root directory of the project.
2.  Execute the following command:
    ```bash
    python -m unittest discover -s tests
    ```
    Or, if you have a specific test file:
    ```bash
    python -m unittest tests.test_lambda_handler
    ```

## Deploying to LocalStack

A helper script `scripts/deploy_local.sh` is provided to demonstrate deploying the Lambda to LocalStack.

1.  **Make the script executable:**
    ```bash
    chmod +x scripts/deploy_local.sh
    ```

2.  **Run the deployment script:**
    ```bash
    ./scripts/deploy_local.sh
    ```
    This script will:
    *   Package the Lambda function into a zip file.
    *   Create an IAM role for the Lambda function (if it doesn't exist).
    *   Create the Lambda function in LocalStack using the zip file and the IAM role.

    **Note:** You might need to customize the `AWS_ENDPOINT_URL` in the script if your LocalStack is running on a different address or port. It defaults to `http://localhost:4566`.

## Invoking the Lambda on LocalStack

Once deployed, you can invoke the Lambda function using the AWS CLI:

1.  **Invoke command:**
    ```bash
    aws lambda invoke         --function-name my-lambda-function         --payload '{"name": "LocalStackUser"}'         --cli-binary-format raw-in-base64-out         --endpoint-url http://localhost:4566         output.json
    ```
    *   Replace `my-lambda-function` with the name you used during deployment (default in script is `my-lambda-function`).
    *   The `--cli-binary-format raw-in-base64-out` is important for AWS CLI v2.
    *   `output.json` will contain the response from the Lambda function.

2.  **Check the output:**
    ```bash
    cat output.json
    ```
    You should also see logs from the Lambda execution in the `localstack` container logs:
    ```bash
    docker-compose logs localstack
    ```

## Cleaning Up

*   **Stop and remove LocalStack containers:**
    ```bash
    docker-compose down
    ```
*   **To remove LocalStack data (if `DATA_DIR` was used and you want a clean slate):**
    You might need to manually remove the directory specified in `DATA_DIR` or the volume used by Docker. For the example `docker-compose.yml`, the data is persisted in `${TMPDIR:-/tmp}/localstack`.

## Further Development

*   Modify `src/lambda_handler.py` to implement your desired Lambda logic.
*   Add more unit tests in the `tests/` directory.
*   Update `requirements.txt` if you add new Python dependencies.
*   If you change dependencies or the `Dockerfile`, rebuild your Lambda image (`docker-compose build app` or `docker build -t my-lambda-app .`).
*   Re-deploy to LocalStack after making changes using the `./scripts/deploy_local.sh` script or your preferred deployment method.
