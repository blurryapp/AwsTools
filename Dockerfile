# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /var/task

# Copy the requirements file into the container at /var/task
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the function code into the container at /var/task
COPY src/ ./src/

# Set the CMD to your handler (this is for AWS Lambda, an ENTRYPOINT or CMD might be different for other uses)
# AWS Lambda will look for a file named lambda_handler.py and a function called lambda_handler
# So we ensure our src/lambda_handler.py is in the PYTHONPATH
# For Lambda, the command is the handler location: <filename>.<handler_function_name>
# This CMD is more for local testing if you were to run the container directly,
# actual Lambda execution doesn't use this CMD in the same way.
CMD [ "src.lambda_handler.lambda_handler" ]
