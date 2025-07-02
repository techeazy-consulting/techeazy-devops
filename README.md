🚀 DevOps Assignment Workflow Summary
--------------------------------------
✅ Assignment 1: Automate EC2 Deployment

## Project Overview
This project demonstrates the deployment of an application to an AWS EC2 instance using Terraform and GitHub Actions. It includes CI/CD deployment with different stages such as dev,qa and prod.

## Steps Performed:
1. AWS Setup: Created IAM user with programmatic access, downloaded AWS credentials.
2. GitHub Setup: Created a personal access token.
3. Project Cloning: Cloned the App repo (techeazy-devops) from GitHub.
4. Terraform Configuration:
   > Created EC2 instance using Terraform.
   > Installed Java 21 on EC2.
   > Cloned the GitHub repo inside EC2 and built the app using mvn clean package.
   > Deployed the .jar file and exposed the app on port 80.
5. Environment Configuration: Used variable-based config for dev, qa, and prod stages.
6. Auto Shutdown: Configured EC2 instance to shut down after a set time for cost saving.

✅ Assignment 2: Extend Automation with S3, IAM, Logging
This assignment added IAM roles, permissions, and automated logging features.

## Steps Performed:
1. IAM Roles:
   > Created two roles:
     🔹 Read-only role for S3
     🔹 Write-only role to create/upload to S3 (no read access)
   > Attached write-only role to EC2 using instance profile.
2. S3 Bucket:
   > Created a private S3 bucket (name configurable via variables).
   > Added lifecycle policy to delete logs after 7 days.
3. Log Upload:
   > Configured EC2 to upload:
     🔹Cloud-init logs to /logs/dev/cloud-init-output-...
     🔹App logs to /logs/dev/app-...
   > Used AWS S3 cp in the shell script for automatic upload after instance shutdown.

## 🚀 Run the Project

```bash
terraform init
terraform apply -var="stage=dev" -var="s3_bucket_name=bucket-abhi-4254"
```

##💡 Tools & Technologies Used
    > AWS EC2, S3, IAM
    > AWS CLI
    > Terraform
    > Bash scripting
    > Git, GitHub
    > Maven
    > Java 21

