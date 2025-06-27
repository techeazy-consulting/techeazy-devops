# Assignment 4: CI/CD Multi-Stage Deployment

## Prerequisites
Before using this project, ensure you have the following:

- *AWS Account*: An active AWS account with programmatic access keys configured.
- *GitHub Account*: A GitHub account where this repository will be hosted.
- *GitHub Secrets*: The following secrets must be configured in your GitHub repository under Settings > Secrets > Actions:
  - AWS_ACCESS_KEY_ID: Your AWS Access Key ID
  - AWS_SECRET_ACCESS_KEY: Your AWS Secret Access Key
  - GH_TOKEN: A GitHub Personal Access Token with repo scope
- *S3 Bucket for Terraform State*: An S3 bucket must be pre-created in your AWS account for storing Terraform state files.


## Project Overview
This project demonstrates the deployment of an application to an AWS EC2 instance using Terraform and GitHub Actions. It includes CI/CD deployment with different stages such as dev,qa and prod.


## Directory Structure
* `.github/workflows`: Contains deploy.yml and destroy.yml file for CI/CD.
* `terraform/`: Contains Terraform configuration files for deploying to EC2

## Deployment Steps

### Trigger Deployment Workflow
1. Navigate to the Actions tab in your GitHub repository
2. Select the "CI/CD Multi-Stage Deployment" workflow
3. Click "Run workflow"
4. Select the desired Deployment Stage (dev, qa, or prod)
5. Click "Run workflow"

### Monitor Deployment
- The workflow run will start and show progress in GitHub Actions
- Green checkmarks indicate successful steps

### Verify Application Health
1. Check the "Validate app health" step output
2. Alternatively, manually verify using the EC2 instance's public IP/DNS:
   - Port 80 (frontend)
   - Port 8080 (backend)

### Access Logs
Application logs will be pushed to your S3 bucket under stage-specific prefixes:
s3://your-bucket-name/logs/dev/
s3://your-bucket-name/logs/qa/
s3://your-bucket-name/logs/prod/


## Destroy the Infrastructure
When infrastructure is no longer needed:

1. *Trigger Destroy Workflow*:
   - Navigate to Actions > Destroy Infrastructure
   - Select the stage to destroy
   - Run workflow

2. *Manually Empty S3 Bucket* (Required before destruction):
   - Go to AWS S3 Console
   - Find the relevant log bucket
   - Select and delete all objects


## Workflow Details
The GitHub Actions workflow is defined in `.github/workflows/deploy.yml`. It performs the following steps:

1. **Checkout code**:  Uses actions/checkout@v3 to clone the repository's code onto the GitHub Actions runner.
2. **Configure AWS credentials**: Uses aws-actions/configure-aws-credentials@v1 to set up AWS credentials on the runner using the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY secrets. The AWS region is also specified here.
3. **Initialize Terraform**: Navigates to the terraform/ directory and runs terraform init to initialize the working directory, download provider plugins, and configure the S3 backend.
4. **Apply Terraform configuration**: Executes terraform apply -auto-approve to provision the infrastructure defined in the terraform/ directory. This step uses variables (e.g., stage, github_pat) passed from the workflow inputs to customize the deployment.
5. **Validate app health**: After successful Terraform application, this step sends an HTTP request to the deployed EC2 instance's public IP/DNS on the relevant port (80 or 8080) to confirm the application is running and reachable. This acts as a basic health check.

## Note:-
```
resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name 

  #force_destroy = true 

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```
i commented force_destroy part in s3 bucket because Manually Empty the Bucket is Safest 
This is the safest method, especially for production environments. You manually empty the bucket using the AWS Management Console or the AWS CLI before running terraform destroy.

