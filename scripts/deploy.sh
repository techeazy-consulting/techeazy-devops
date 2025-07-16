#!/bin/bash
set -e

# For logging all output
exec > >(tee /var/log/deploy.log | logger -t deploy-script) 2>&1

# Check for bucket name
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./deploy.sh <bucket_name> <stage>"
  exit 1
fi

bucket_name=$1
stage = $2

echo "Starting deployment for stage: $stage"


# Install Java and Git
sudo yum update -y
sudo yum install -y java-21-amazon-corretto git

# Move to the already-cloned repo (GitHub Action cloned this!)
cd /home/ec2-user/techeazy-devops

# Give ownership to ec2-user
sudo chown -R ec2-user:ec2-user .

# Copy stage-based config to app folder
cp /home/ec2-user/techeazy-devops/terraform/${stage}.json /homeec2-user/techeazy-devops/configs/config.json

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

# Upload logs to S3 with stage-based path
aws s3 cp /home/ec2-user/app.log s3://${bucket_name}/logs/${stage}/app.log
aws s3 cp /var/log/cloud-init.log s3://${bucket_name}/logs/${stage}/cloud-init.log

# At the end of deploy.sh (after build)
CONFIG_FILE="/home/ec2-user/techeazy-devops/configs/${stage}.json"
DEST="/home/ec2-user/techeazy-devops/configs/config.json"

cp "$CONFIG_FILE" "$DEST"
echo "Copied $CONFIG_FILE to $DEST"


echo "Deployement complete for stage : $stage"