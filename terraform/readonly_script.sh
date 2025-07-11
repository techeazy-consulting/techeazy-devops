#!/bin/bash

sudo apt update
sudo apt install -y awscli
aws s3 ls s3://${BUCKET_NAME} --region ${AWS_REGION_FOR_SCRIPT} > /home/ubuntu/s3_list_output.txt
