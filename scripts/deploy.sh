#!/bin/bash

set -e

# For logging all output
exec > >(tee /var/log/deploy.log | logger -t deploy-script) 2>&1

# Check for bucket name
if [ -z "$1" ]; then
  echo "Usage: ./deploy.sh <bucket_name>"
  exit 1
fi

bucket_name=$1

echo "Starting deployment process..."

# Stop any existing Java application
echo "Stopping existing application..."
pkill -f "java.*techeazy" || echo "No existing application to stop"

# Pull latest changes
echo "Pulling latest changes..."
git pull origin main

# Build project
echo "Building project..."
./mvnw clean package -DskipTests

JAR_PATH="target/techeazy-devops-0.0.1-SNAPSHOT.jar"

if [ -f "$JAR_PATH" ]; then
  echo "JAR built successfully. Starting application..."
  
  # Start the application on port 80
  nohup sudo java -jar "$JAR_PATH" --server.port=80 > /home/ec2-user/app.log 2>&1 &
  
  # Wait for application to start
  sleep 10
  
  # Check if application is running
  if pgrep -f "java.*techeazy" > /dev/null; then
    echo "Application started successfully"
  else
    echo "Failed to start application"
    exit 1
  fi
else
  echo "Build failed. JAR file not found."
  exit 1
fi

# Upload logs to S3 bucket
echo "Uploading logs to S3..."
aws s3 cp /home/ec2-user/app.log s3://${bucket_name}/app/logs/ || echo "Failed to upload app.log"
aws s3 cp /var/log/deploy.log s3://${bucket_name}/app/logs/ || echo "Failed to upload deploy.log"

echo "Deployment completed successfully"