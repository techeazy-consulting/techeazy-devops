#!/bin/bash
set -e

# Log everything
exec > >(tee /var/log/deploy.log | logger -t deploy-script) 2>&1

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./deploy.sh <bucket_name> <stage>"
  exit 1
fi

bucket_name=$1
stage=$2

echo "Starting deployment for stage: $stage"

# Install Java and Git
sudo yum update -y
sudo yum install -y java-21-amazon-corretto git

# Decide repo URL based on token availability
if [ -f /home/ec2-user/token.txt ]; then
  github_token=$(cat /home/ec2-user/token.txt)
  git clone --branch "$stage" https://${github_token}@github.com/sohampatil44/techeazy-devops.git
else
  git clone --branch "$stage" https://github.com/sohampatil44/techeazy-devops.git
fi

cd /home/ec2-user/techeazy-devops
sudo chown -R ec2-user:ec2-user .

# Copy config
CONFIG_FILE="/home/ec2-user/techeazy-devops/configs/${stage}.json"
DEST="/home/ec2-user/techeazy-devops/configs/config.json"
cp "$CONFIG_FILE" "$DEST"
echo "Copied $CONFIG_FILE to $DEST"

# Build
chmod +x mvnw
sudo -u ec2-user ./mvnw clean package

JAR_PATH="target/techeazy-devops-0.0.1-SNAPSHOT.jar"

if [ -f "$JAR_PATH" ]; then
  echo "Running app..."
  sudo nohup java -jar "$JAR_PATH" --server.port=80 > /home/ec2-user/app.log 2>&1 &
else
  echo "Build failed. JAR file not found."
  exit 1
fi

# Upload logs to S3
aws s3 cp /home/ec2-user/app.log s3://${bucket_name}/logs/${stage}/app.log
aws s3 cp /var/log/cloud-init.log s3://${bucket_name}/logs/${stage}/cloud-init.log

echo "Deployment complete for stage: $stage"
