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

# Install Java and Git
sudo yum update -y
sudo yum install -y java-21-amazon-corretto git

# Move to the already-cloned repo (GitHub Action cloned this!)
cd /home/ec2-user/techeazy-devops

# Give ownership to ec2-user
sudo chown -R ec2-user:ec2-user .

# Make Maven wrapper executable
chmod +x mvnw

# Build project
sudo -u ec2-user ./mvnw clean package

JAR_PATH="target/techeazy-devops-0.0.1-SNAPSHOT.jar"

# Run the app if JAR exists
if [ -f "$JAR_PATH" ]; then
  echo "Running app..."
  sudo nohup java -jar "$JAR_PATH" --server.port=80 > /home/ec2-user/app.log 2>&1 &
else
  echo "Build failed. JAR file not found."
  exit 1
fi

# Upload logs to S3
aws s3 cp /home/ec2-user/app.log s3://${bucket_name}/app/logs/
aws s3 cp /var/log/cloud-init.log s3://${bucket_name}/system/
