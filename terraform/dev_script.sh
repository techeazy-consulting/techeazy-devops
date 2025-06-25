#!/bin/bash

REPO_URL="${repo_url}"
JAVA_VERSION="${java_version}"
REPO_DIR_NAME="${repo_dir_name}"
STOP_INSTANCE="${stop_after_minutes}"

# Install AWS CLI v2 manually
if ! command -v aws &> /dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

git clone "$REPO_URL"
sudo apt update  
sudo apt install "$JAVA_VERSION" -y
apt install maven -y
cd "$REPO_DIR_NAME"
chmod +x mvnw

#build artifact
./mvnw clean package

# Run the app
nohup $JAVA_HOME/bin/java -jar target/*.jar > app.log 2>&1 &

# --- Upload cloud-init logs to S3 ---
echo "Uploading cloud-init-output.log to S3 bucket ${S3_BUCKET_NAME}..."
# Give cloud-init a moment to finish writing its logs.
sleep 10
# Upload the log. The '|| true' prevents the script from exiting if upload fails
# (e.g., due to transient S3 issues), allowing the rest of the script to complete.
aws s3 cp /var/log/cloud-init-output.log "s3://${S3_BUCKET_NAME}/app/logs/dev/cloud-init-output-$(hostname)-$(date +%Y%m%d%H%M%S).log" \
    --region "${AWS_REGION_FOR_SCRIPT}" || true # CRITICAL: --region must be here!
echo "Cloud-init log upload attempted."

sudo shutdown -h +"$STOP_INSTANCE"  
