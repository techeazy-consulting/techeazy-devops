#!/bin/bash

REPO_URL="${repo_url}"
JAVA_VERSION="${java_version}"
REPO_DIR_NAME="${repo_dir_name}"
STOP_INSTANCE="${stop_after_minutes}"

git clone "$REPO_URL"
sudo apt update  
sudo apt install "$JAVA_VERSION" -y
apt install maven -y
cd "$REPO_DIR_NAME"
mvn spring-boot:run &

aws s3 cp /var/log/cloud-init-output.log s3://"${s3_bucket_name}"/app/logs/cloud-init-output-$(hostname)-$(date +%Y%m%d%H%M%S).log
sudo shutdown -h +"$STOP_INSTANCE"  
