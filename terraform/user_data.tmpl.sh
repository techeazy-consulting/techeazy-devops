#!/bin/bash

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

# Fail if BUCKET_NAME is not set
if [ -z "${bucket_name}" ]; then
  echo "S3 bucket name not provided. Exiting..."
  exit 1

fi  

# Update and install required packages
yum update -y
yum install -y java-21-amazon-corretto git

# Go to ec2-user's home
cd /home/ec2-user

# Clone the official repo
git clone https://github.com/techeazy-consulting/techeazy-devops.git
cd techeazy-devops

# Set proper ownership
chown -R ec2-user:ec2-user /home/ec2-user/techeazy-devops

# Make Maven wrapper executable
chmod +x mvnw

# Build using mvn clean package
sudo -u ec2-user ./mvnw clean package

# Path to built JAR
JAR_PATH="/home/ec2-user/techeazy-devops/target/techeazy-devops-0.0.1-SNAPSHOT.jar"

# Only run if JAR was built successfully
if [ -f "$JAR_PATH" ]; then
  echo "JAR built successfully at $JAR_PATH"

  # Start the application on port 80 (requires root)
  nohup java -jar "$JAR_PATH" --server.port=80 > /home/ec2-user/app.log 2>&1 &
else
  echo "Build failed. JAR file not found."
fi

# Upload logs

aws s3 cp /var/log/cloud-init.log s3://${bucket_name}/system/
aws s3 cp /home/ec2-user/app.log s3://${bucket_name}/app/logs
