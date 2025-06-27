# Assignment 4: CI/CD  Multi-Stage Deployment

## Prerequisite
* 'Aws access_key_id', 'secret access_key_id' and 'github_token" configured in github secrets.
* One s3 bucket already created to use it to store terraform.tfstate file.

## Project Overview
This project demonstrates the deployment of an application to an AWS EC2 instance using Terraform and GitHub Actions. It includes CI/CD deployment with different stages such as dev,qa and prod.


## Directory Structure
* `.github/workflows`: Contains deploy.yml and destroy.yml file for CI/CD.
* `terraform/`: Contains Terraform configuration files for deploying to EC2

## How to Use
1. **You can trigger workflow manually by clinking on run workflow button on Actions tab. It supports different stages (e.g., dev, qa, prod).
2. **Stage-Specific Configuration Files:** Separate configuration files (e.g., dev.json, prod.json, qa.json) are maintained within the project repository.
3. **Configurable Repository Source:** For dev environments, configurations might be pulled from a public repository for easier access and sharing, while prod environments strictly pull from a private, more secure repository.
4. **Stage-Based S3 Log Upload**
    These logs are then pushed to dedicated, stage-specific folders within an S3 bucket, following a clear structure:
    s3://your-bucket/logs/dev/...
    s3://your-bucket/logs/qa/...
    s3://your-bucket/logs/prod/...
    This organization facilitates easier log analysis, auditing, and debugging for specific environments.

5. **Destroy the infrastructure**


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

