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
1. **You can trigger workflow manually by clinking on run workflow button on Actions tab.

3. **Destroy the infrastructure**


## Workflow Details
The GitHub Actions workflow is defined in `.github/workflows/deploy.yml`. It performs the following steps:

1. **Checkout code**: Checks out the code in the repository.
2. **Configure AWS credentials**: Configures AWS credentials using secrets stored in the repository.
3. **Initialize Terraform**: Initializes Terraform in the `terraform/` directory.
4. **Apply Terraform configuration**: Applies the Terraform configuration to deploy to EC2.
5. **Validate app health**: Validates the health of the application by sending a request to the EC2 instance.

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

