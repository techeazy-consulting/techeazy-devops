# Terraform Setup: Grafana with AWS Athena for GitHub Actions Logs
This Terraform configuration automates the deployment of the necessary AWS infrastructure to enable monitoring and visualization of GitHub Actions workflow failure logs using Grafana and AWS Athena.

## GitHub Actions Workflow for Log Upload (upload_failed_logs.yml) :- 
This workflow is designed to automatically capture and upload logs from failed GitHub Actions workflow runs to your designated S3 bucket. Also it sends alert message to admin.

## Key Components Deployed
  This Terraform code provisions the following AWS resources:
 **Amazon S3 Buckets:**
  One for storing raw GitHub Actions workflow logs.
  One dedicated bucket for Athena query results (with an aggressive lifecycle policy for cost optimization).

  **AWS IAM:**
  An IAM Role and Instance Profile for the Grafana EC2 instance, granting it secure, temporary credentials to interact with Athena, S3, and Glue.
  Necessary IAM Policies to define precise permissions.

  **Amazon EC2 Instance:**
  A virtual server that hosts the Grafana application (running in a Docker container).

  **AWS Glue Data Catalog:**
  A database and table definition that tells Athena how to interpret the structure of your raw log files in S3.

## How to Use This Code
  Initialize Terraform:
  ```
  cd admin-alerting-setup
  terraform init
  terraform apply
  ```
# Notification for admim
![Image of contact form error message](https://github.com/user-attachments/assets/ec4ebf93-0d89-4665-b359-0f855cf58a7c)

## Setup Grafana locally
```
sudo apt update
sudo apt install docker.io -y
sudo  usermod -aG docker ubuntu
newgrp docker 
docker volume create grafana-storage
docker run -d -p 3000:3000 --name grafana --volume grafana-storage:/var/lib/grafana grafana/grafana-enterprise
```

login admin:admin

connections > search amazon athena > install > add 
name= GitHub Actions Failure Logs
Default Region: us-east-1
Athena Output Location: s3://sumit-4254/athena-query-results/
Database: github_actions_logs
Workgroup: primary

save &  test

## Athena Deatils
![athena](https://github.com/user-attachments/assets/b41b820e-fa95-42d9-983a-d64c28534027)

dashboard > virtualization > run query
```
SELECT log_entry
FROM github_actions_logs.workflow_failure_logs
WHERE log_entry LIKE '%error%' -- Look for lines containing "error"
   OR log_entry LIKE '%failed%' -- Or "failed"
   OR log_entry LIKE '%fatal%' -- Or "fatal"
   OR log_entry LIKE '%exception%' -- Or "exception"
   -- Add other keywords relevant to your infrastructure destroy process (e.g., 'denied', 'permission', 'resource not found', 'invalid argument')
LIMIT 50;
```
# deasboard after running query it showing errors of different workflows.
![grafana](https://github.com/user-attachments/assets/a8c450c1-53e7-4803-9142-ab716ec9e951)

