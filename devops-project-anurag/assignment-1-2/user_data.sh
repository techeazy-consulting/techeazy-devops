#!/bin/bash
# Install Java and deploy app on EC2
sudo yum update -y
sudo amazon-linux-extras enable java-openjdk11
sudo amazon-linux-extras install java-openjdk11 -y

cd /home/ec2-user
git clone https://github.com/techeazy-consulting/techeazy-devops
cd techeazy-devops
chmod +x deploy.sh
./deploy.sh &

# Upload logs to S3
aws s3 cp /var/log/cloud-init.log s3://devops-anurag-logs/cloud-init-$(date +%s).log

# Shutdown after 30 minutes to save cost
echo "sudo shutdown -h now" | at now + 30 minutes
