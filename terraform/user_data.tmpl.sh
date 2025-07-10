#!/bin/bash

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

# Update and install required packages
yum update -y
yum install -y java-21-amazon-corretto git nc

# Go to ec2-user's home
cd /home/ec2-user

# Clone the official repo
git clone https://github.com/sohampatil44/techeazy-devops.git

cd techeazy-devops

# Set proper ownership
chown -R ec2-user:ec2-user /home/ec2-user/techeazy-devops

# Make Maven wrapper executable
chmod +x mvnw

# Make deploy script executable
chmod +x scripts/deploy.sh

# Upload initial logs if bucket_name is provided
if [ -n "${bucket_name}" ]; then
  aws s3 cp /var/log/cloud-init.log s3://${bucket_name}/system/ || echo "Failed to upload cloud-init.log"
fi

echo "User data script completed successfully"