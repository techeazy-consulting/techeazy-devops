# Assignment 4: CI/CD  Multi-Stage Deployment

## Prerequisite
* 'Aws access_key_id', 'secret access_key_id' and 'github_token" configured in github secrets.
* One s3 bucket already created to use it to store terraform.tfstate file.

## Project Overview
This project demonstrates the deployment of an application to an AWS EC2 instance using Terraform and GitHub Actions. It includes CI/CD deployment with different stages. 

## Directory Structure
* `.github/workflows`: Contains deploy.yml and destroy.yml file for CI/CD.
* `terraform/`: Contains Terraform configuration files for deploying to EC2
* `.github/workflows/`: Contains GitHub Actions workflow files for automating deployment

## How to Use
1. **You can trigger workflow manually by clinking on run workflow button on Actions tab.
  workflow:**
    - Asks for Deployment stage parameter, only dev, qa and prod is valid. default is dev.
    - creates infrastructure:- ec2,s3, security group, iam instance profile,iam role,iam policy based on parameter you've passed.
    - the production stage is  expremely secure.
    - the terraform state file will be located at the s3 bucket we already created, you have to mention it on backend.tf
    - the script will deploy the application on ec2, application will be accesssible via port 80.
    - before testing the application we will wait for 2 mins because our application needs time to execute and run.
    - now application is running you  can see it's public_ip in output and access the application.
    - to save cost the ec2 instance will be stopped after 10 mins as we specify in terraform.tfvars


3. **Destroy the infrastructure**
    - to destroy the infrastructure we have to commit on "github/workflows/destroy.yml" file.
    - it will trigger the workflow to destroy the infrastructure.


## Workflow Details
The GitHub Actions workflow is defined in `.github/workflows/deploy.yml`. It performs the following steps:

1. **Checkout code**: Checks out the code in the repository.
2. **Configure AWS credentials**: Configures AWS credentials using secrets stored in the repository.
3. **Initialize Terraform**: Initializes Terraform in the `terraform/` directory.
4. **Apply Terraform configuration**: Applies the Terraform configuration to deploy to EC2.
5. **Validate app health**: Validates the health of the application by sending a request to the EC2 instance.
6. **Destroy Infrastructure** Destroys the infrastrucure.

## Future/incomplete work
* GitHub Token Handling
* Config Separation
