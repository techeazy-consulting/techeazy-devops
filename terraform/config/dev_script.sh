#!/bin/bash

echo "Starting user data script execution..."


REPO_URL="${REPO_URL}"
JAVA_VERSION="${JAVA_VERSION}"
REPO_DIR_NAME="${REPO_DIR_NAME}"
STOP_INSTANCE="${STOP_INSTANCE}"
S3_BUCKET_NAME="${S3_BUCKET_NAME}"          # Corrected: Now matches uppercase from Terraform
AWS_REGION_FOR_SCRIPT="${AWS_REGION_FOR_SCRIPT}" # NEW: This variable is now correctly received


sudo apt update  
sudo apt install unzip -y
# Install AWS CLI v2 manually
if ! command -v aws &> /dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

sudo apt install "$JAVA_VERSION" -y
sudo apt install maven -y

export HOME=/root
echo "HOME environment variable set to: $HOME"

# -----------------------------------------------------------------------------
# --- Clone and Run Application ---
# -----------------------------------------------------------------------------

cd /opt
git clone "$REPO_URL"
cd "$REPO_DIR_NAME"
chmod +x mvnw

#build artifact
./mvnw clean package

# Run the app
nohup $JAVA_HOME/bin/java -jar target/*.jar > app.log 2>&1 &
echo "Application started in background."


# Give the application a moment to start and generate some logs
sleep 15

# -----------------------------------------------------------------------------
# --- CloudWatch Agent Installation and Configuration (for Debian/Ubuntu) ---
# -----------------------------------------------------------------------------
sudo apt-get update
sudo apt-get install collectd -y

echo "Downloading CloudWatch Agent .deb package..."
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb


echo "Installing CloudWatch Agent .deb package..."
sudo dpkg -i /tmp/amazon-cloudwatch-agent.deb
rm /tmp/amazon-cloudwatch-agent.deb # Clean up installer

echo "Writing CloudWatch Agent config.json..."
# Write the config.json content passed from Terraform into the agent's bin directory
cat << 'EOF_CONFIG_JSON' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
${CW_AGENT_CONFIG_JSON}
EOF_CONFIG_JSON

echo "Fetching CloudWatch Agent config and starting agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

# --- Run the application ---
# Define APP_LOG_PATH as a shell variable
APP_LOG_PATH="/opt/${REPO_DIR_NAME}/app.log" # This line is correct



# -----------------------------------------------------------------------------
# --- Upload cloud-init logs to S3 ---
# -----------------------------------------------------------------------------

sleep 30
aws s3 cp /var/log/cloud-init-output.log "s3://${S3_BUCKET_NAME}/logs/dev/cloud-init-output-$(hostname)-$(date +%Y%m%d%H%M%S).log" 
    --region "${AWS_REGION_FOR_SCRIPT}" || true # CRITICAL: --region must be here!
echo "Cloud-init log upload attempted."

aws s3 cp app.log "s3://${S3_BUCKET_NAME}/logs/dev/app-$(hostname)-$(date +%Y%m%d%H%M%S).log" \
    --region "${AWS_REGION_FOR_SCRIPT}" || true # CRITICAL: --region must be here!
echo "Application log upload attempted."

# Shutdown the instance after the specified time
sudo shutdown -h +"$STOP_INSTANCE"  

