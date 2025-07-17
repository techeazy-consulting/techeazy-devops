#!/bin/bash

REPO_URL="${REPO_URL}"
REPO_IS_PRIVATE="${REPO_IS_PRIVATE}"
GITHUB_TOKEN="${GITHUB_TOKEN}"
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

cd /opt

# Clone based on repo visibility
if [ "$REPO_IS_PRIVATE" = "true" ]; then
  git clone https://$GITHUB_TOKEN@github.com/abhinayakumar130/tech_eazy_devops_private.git
else
  git clone https://github.com/abhinayakumar130/tech_eazy_devops_abhinayakumar130.git
fi

cd "$REPO_DIR_NAME"
chmod +x mvnw

#build artifact
./mvnw clean package

# Run the app
nohup $JAVA_HOME/bin/java -jar target/*.jar > app.log 2>&1 &

# --- Upload cloud-init logs to S3 ---
sleep 30
aws s3 cp /var/log/cloud-init-output.log "s3://${S3_BUCKET_NAME}/logs/prod/cloud-init-output-$(hostname)-$(date +%Y%m%d%H%M%S).log" 
    --region "${AWS_REGION_FOR_SCRIPT}" || true # CRITICAL: --region must be here!
echo "Cloud-init log upload attempted."

aws s3 cp app.log "s3://${S3_BUCKET_NAME}/logs/prod/app-$(hostname)-$(date +%Y%m%d%H%M%S).log" \
    --region "${AWS_REGION_FOR_SCRIPT}" || true # CRITICAL: --region must be here!
echo "Application log upload attempted."

# Shutdown the instance after the specified time
sudo shutdown -h +"$STOP_INSTANCE"  
