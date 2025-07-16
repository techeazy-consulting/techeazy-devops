#!/bin/bash
set -e

# Ensure log file is writable
LOG_FILE="/home/ec2-user/deploy.log"
touch "$LOG_FILE"
chmod 666 "$LOG_FILE"

# Log everything
exec > >(tee "$LOG_FILE" | logger -t deploy-script) 2>&1

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./deploy.sh <bucket_name> <stage>"
  exit 1
fi

bucket_name=$1
stage=$2

echo "🚀 Starting deployment for stage: $stage"
echo "🪣 S3 Bucket: $bucket_name"

# Step 1: Install Java and Git
echo "📦 Updating yum packages..."
sudo yum update -y || { echo "❌ yum update failed"; exit 1; }

echo "📦 Installing Java 21 and Git..."
sudo yum install -y java-21-amazon-corretto git || { echo "❌ Java or Git install failed"; exit 1; }

# Step 2: Change to app directory
cd /home/ec2-user/techeazy-devops || { echo "❌ Could not cd to repo directory"; exit 1; }
sudo chown -R ec2-user:ec2-user .

# Step 3: Copy config file
CONFIG_FILE="/home/ec2-user/techeazy-devops/configs/${stage}.json"
DEST="/home/ec2-user/techeazy-devops/configs/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

cp "$CONFIG_FILE" "$DEST" || { echo "❌ Failed to copy config file"; exit 1; }
echo "✅ Copied $CONFIG_FILE to $DEST"

# Step 4: List files before build
echo "📂 Files before build:"
ls -la || echo "⚠️ Failed to list files"

# Step 5: Maven Build
echo "🔧 Starting Maven build..."
chmod +x mvnw || { echo "❌ Failed to chmod mvnw"; exit 1; }
sudo -u ec2-user ./mvnw clean package || { echo "❌ Maven build failed"; exit 1; }

# Step 6: Run JAR if build was successful
JAR_PATH="target/techeazy-devops-0.0.1-SNAPSHOT.jar"

if [ -f "$JAR_PATH" ]; then
  echo "🚀 Running app..."
  sudo nohup java -jar "$JAR_PATH" --server.port=80 > /home/ec2-user/app.log 2>&1 &
else
  echo "❌ Build failed. JAR file not found at $JAR_PATH"
  exit 1
fi

# Step 7: Upload logs to S3
echo "☁️ Uploading logs to S3..."
aws s3 cp /home/ec2-user/app.log s3://${bucket_name}/logs/${stage}/app.log || echo "⚠️ Failed to upload app.log"
aws s3 cp /var/log/cloud-init.log s3://${bucket_name}/logs/${stage}/cloud-init.log || echo "⚠️ Failed to upload cloud-init.log"

echo "✅ Deployment complete for stage: $stage"
