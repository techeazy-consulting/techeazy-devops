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
sudo shutdown -h +"$STOP_INSTANCE"  # Stops the instance after 2 minutes 