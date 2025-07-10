# 🚀 DevOps Internship Project – AWS EC2, S3, Terraform & GitHub Actions
This project showcases how to provision, configure, and deploy EC2 instances using Terraform and GitHub Actions. It also includes S3 bucket management, IAM roles, and CI/CD deployment with environment-specific staging.


## ✅ Assignments Covered

- Assignment 1: EC2 provisioning with Java install, GitHub repo clone, and app deployment.

- Assignment 2: S3 Bucket creation with lifecycle policies, IAM roles (read-only/write-only), and log uploads.

- Assignment 3: CI/CD pipeline for multi-stage deployments (dev, qa, prod) using GitHub Actions.


## 🧰 Prerequisites
- AWS Account (with access key/secret)

- GitHub Account

- GitHub Secrets configured:

     - AWS_ACCESS_KEY_ID

     - AWS_SECRET_ACCESS_KEY

     - GH_TOKEN (with repo access)

- S3 bucket already created (for remote Terraform state)

## ✅ Assignment Summary
📌 **Assignment 1: EC2 Instance Deployment using Terraform**
     
  - Provision an EC2 instance using Terraform.

  - Automatically install Java, clone a GitHub repo, and run your app.

  - Configure user_data using a shell script for automation.

📌 **Assignment 2: EC2 + S3 Integration**
     
  - Create an S3 bucket with:

       - Private access

       - Lifecycle configuration

  - Assign IAM roles to EC2 with S3 read/write permissions.

  - Logs from EC2 are pushed to the respective stage’s S3 path.

  - Validate S3 access using aws s3 ls and role permissions.

📌 **Assignment 3: CI/CD Multi-Stage Deployment with GitHub Actions**

  - Setup GitHub Actions to handle:

       - Deployment (deploy.yml)

       - Destruction (destroy.yml)

  - Use tags like deploy-dev, deploy-qa, etc., or manual trigger with environment input.

  - Environments: dev, qa, prod

  - Health check added post-deployment to validate the running app on port 80.

## 🚀 How It Works

**1️⃣ Trigger Deployment**

Via GitHub:

 - Go to Actions > Deploy to EC2 via Terraform

 - Click Run workflow

 - Select environment: dev / qa / prod

 - Or push a tag like: deploy-dev, deploy-prod

**2️⃣ GitHub Actions Flow (deploy.yml)**

 - Sets environment stage based on input or tag

 - Initializes Terraform

 - Applies configuration using stage.json and user_data script

 - Waits for EC2 to be ready

 - Performs health check on port 80

**3️⃣ EC2 Instance Setup**

 - Runs user_data shell script:

 - Installs Java

 - Clones your GitHub repository

 - Starts the application

 - Uploads logs to S3 in path:

       s3://your-bucket-name/logs/dev/
       s3://your-bucket-name/logs/qa/
       s3://your-bucket-name/logs/prod/

**4️⃣ Monitor Deployment**

  - The workflow run will start and show progress in GitHub Actions

  - Green checkmarks indicate successful steps

**5️⃣ Destroy Infrastructure**

To tear down:

  - Go to Actions > Destroy Infrastructure via Terraform

  - Run workflow and select the stage


## 🧪 Health Check Logic

 - After EC2 deployment, GitHub Actions:

     - Waits for public IP

     - Pings http://<EC2_IP> on port 80


## 📌 Notes
    
    1. Each stage uses its own .json config and shell script.

    2. Backend state is stored in a pre-created S3 bucket.

    3. IAM role policies ensure only that instance can access its environment's logs.
