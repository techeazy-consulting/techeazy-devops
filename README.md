# Assignment 4: CI/CD  Multi-Stage Deployment

## Prerequisites
Before using this project, ensure you have the following:

**AWS Account:** An active AWS account with programmatic access keys configured.

**GitHub Account:** A GitHub account where this repository will be hosted.

**GitHub Secrets:** The following secrets must be configured in your GitHub repository under Settings > Secrets > Actions:

**AWS_ACCESS_KEY_ID:** Your AWS Access Key ID.

**AWS_SECRET_ACCESS_KEY:** Your AWS Secret Access Key.

**GH_TOKEN:** A GitHub Personal Access Token with repo scope, used for accessing private configuration repositories (if applicable).
**S3 Bucket for Terraform State**: An S3 bucket must be pre-created in your AWS account. This bucket will be used by Terraform to store its state file (terraform.tfstate), enabling remote state management and collaboration.


## Project Overview
This project demonstrates the deployment of an application to an AWS EC2 instance using Terraform and GitHub Actions. It includes CI/CD deployment with different stages such as dev,qa and prod.


## Directory Structure
* `.github/workflows`: Contains deploy.yml and destroy.yml file for CI/CD.
* `terraform/`: Contains Terraform configuration files for deploying to EC2

Deployment Steps
Trigger Deployment Workflow:

Navigate to the Actions tab in your GitHub repository.

Select the CI/CD Multi-Stage Deployment workflow from the left sidebar.

Click on Run workflow on the right side.

In the "Run workflow" dialog, select the desired Deployment Stage (dev, qa, or prod) from the dropdown.

Click the Run workflow button to initiate the deployment.

Monitor Deployment:

The workflow run will start, and you can monitor its progress in the GitHub Actions interface.

Upon successful completion, you will see green checkmarks next to each step.

Verify Application Health:

The Validate app health step will attempt to reach your deployed application. Check its output for success or failure.

You can also manually verify by getting the public IP or DNS name of your EC2 instance from the AWS console and testing the application on ports 80 (frontend) or 8080 (backend).

Access Logs:

After deployment, application and deployment logs will be pushed to your S3 bucket under the stage-specific prefix (e.g., s3://your-bucket-name/logs/dev/).

Destroy the Infrastructure
When you no longer need the deployed infrastructure for a specific stage:

Trigger Destroy Workflow:

Navigate to the Actions tab in your GitHub repository.

Select the Destroy Infrastructure workflow.

Click on Run workflow on the right side.

In the "Run workflow" dialog, select the Deployment Stage you wish to destroy.

Click the Run workflow button.

Manually Empty S3 Bucket (Crucial for terraform destroy):

Before running the destroy.yml workflow, you must manually empty the S3 bucket that Terraform created to store your application logs (e.g., s3://your-bucket-name/logs/dev/...). This is a safety measure, as Terraform's destroy command cannot remove non-empty buckets by default without force_destroy = true set, which is intentionally avoided for safety (see "S3 Bucket Note").

Go to the AWS S3 Console, find the relevant log bucket, select all objects, and delete them.


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

