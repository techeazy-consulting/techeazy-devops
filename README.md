# Assignment 3: Deploying to EC2 using Terraform and GitHub Actions

## Prerequisite
aws access_key_id and secret access_key_id configured in github secrets.
one s3 bucket already created to use it to store terraform.tfstate file.

## Project Overview
This project demonstrates the deployment of an application to an AWS EC2 instance using Terraform and GitHub Actions.

## Directory Structure
* `terraform/`: Contains Terraform configuration files for deploying to EC2
* `.github/workflows/`: Contains GitHub Actions workflow files for automating deployment

## How to Use
1. **Configure AWS credentials**: Set up your AWS credentials as secrets in your GitHub repository settings.
2. **Trigger the workflow**: Push changes to the `assignment-3` branch or trigger the workflow manually using the GitHub Actions UI.

## Workflow Details
The GitHub Actions workflow is defined in `.github/workflows/deploy.yml`. It performs the following steps:

1. **Checkout code**: Checks out the code in the repository.
2. **Configure AWS credentials**: Configures AWS credentials using secrets stored in the repository.
3. **Initialize Terraform**: Initializes Terraform in the `terraform/` directory.
4. **Apply Terraform configuration**: Applies the Terraform configuration to deploy to EC2.
5. **Validate app health**: Validates the health of the application by sending a request to the EC2 instance.
6. **Destroy Infrastructure** Destroys the infrastrucure.

## Troubleshooting
* Check the GitHub Actions logs for errors or issues during deployment.
* Verify that your AWS credentials are set up correctly as secrets in your repository settings.

## Submission
This project is submitted as part of Assignment 3. Please review the project requirements and ensure that all necessary components are included.

## Future/incomplete work
* Passing stage parameter via Github input
* Terrform file gets lost.
