#!/bin/bash
set -e

# Ensure log file is writable
LOG_FILE="/home/ec2-user/deploy.log"
touch "$LOG_FILE"
chmod 666 "$LOG_FILE"

# Log everything
echo "Checking if logger exists..."
if ! command -v logger >/dev/null 2>&1; then
  echo "⚠️ logger not found — this might cause script failure"
fi

exec > >(tee "$LOG_FILE") 2>&1

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./deploy.sh <bucket_name> <stage>"
  exit 1
fi

bucket_name=$1
stage=$2

echo "Starting deployment for stage: $stage"
echo "Bucket: $bucket_name, Stage: $stage"

# Install Java and Git (suppress verbose output)
echo "📦 Installing Java and Git..."
sudo yum update -y -q
sudo yum install -y -q java-21-amazon-corretto git
echo "✅ Java and Git installed"

cd /home/ec2-user/techeazy-devops
sudo chown -R ec2-user:ec2-user .

# Debug the directory before build
echo "📁 Current Directory Before Build:"
pwd
ls -la

# Copy config
CONFIG_FILE="/home/ec2-user/techeazy-devops/configs/${stage}.json"
DEST="/home/ec2-user/techeazy-devops/configs/config.json"
echo "📄 Copying config from $CONFIG_FILE to $DEST"
cp "$CONFIG_FILE" "$DEST"
echo "✅ Config copied successfully"

# Build with reduced Maven output
echo "🔨 Building application..."
chmod +x mvnw

# Suppress Maven download progress and use quiet mode
sudo -u ec2-user ./mvnw clean package -q -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn

JAR_PATH="target/techeazy-devops-0.0.1-SNAPSHOT.jar"

# Verify JAR file existence
if [ -f "$JAR_PATH" ]; then
  echo "✅ Build successful - JAR file created"
  echo "🚀 Starting application..."
  sudo nohup java -jar "$JAR_PATH" --server.port=80 > /home/ec2-user/app.log 2>&1 &
  echo "✅ Application started successfully"
else
  echo "❌ Build failed. JAR file not found."
  exit 1
fi

# Upload logs to S3
echo "☁️ Uploading logs to S3..."
aws s3 cp /home/ec2-user/app.log s3://${bucket_name}/logs/${stage}/app.log --quiet
aws s3 cp /var/log/cloud-init.log s3://${bucket_name}/logs/${stage}/cloud-init.log --quiet
echo "✅ Logs uploaded successfully"

echo "🎉 Deployment complete for stage: $stage"