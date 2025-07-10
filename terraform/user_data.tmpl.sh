#!/bin/bash

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

# Install required packages
yum update -y
yum install -y java-21-amazon-corretto git
