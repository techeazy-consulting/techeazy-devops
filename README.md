# EC2 Instance Deployment with Terraform (Dev/Prod Stages)

This project automates the deployment of an EC2 instance, configures it with Java and Maven, clones a specified Git repository, and runs a Spring Boot application. It supports separate "Dev" and "Prod" stages with different configurations using Terraform workspaces.

## Prerequisites

Before you begin, ensure you have the following:

*   AWS CLI and Terraform installed


## Steps to Run the Application


1.  **Configure AWS Credentials:**

    ```bash
    aws configure
    ```

    Follow the prompts to enter your AWS Access Key ID, Secret Access Key, region, and output format.  **Important:** Do *not* hardcode credentials in the repository.


2.  **Clone the repository:**

    ```bash
    git clone https://github.com/sumit-patil-24/tech_eazy_sumit-patil-24_aws_internship.git
    cd tech_eazy_sumit-patil-24_aws_internship/terraform
    ```


3.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

4.  **Generate an SSH Key Pair (if you don't have one):**

    If you don't already have an SSH key pair, you can generate one using the following command:

    ```bash
    ssh-keygen -t rsa
    ```
    insert "new-key.pem" after it ask for something

    This will create a private key (`~/.ssh/id_rsa`) and a public key (`~/.ssh/id_rsa.pub`).  **Important:**  Keep the private key secure.  You will need it to connect to the EC2 instance.  The public key will       be associated with the instance via the `key_name_value` variable.

NOTE:- add credentials in terraform.tfvars or dec.tfvars or prod.tfvars file.
    task of passing different stage through variables is not completed so use "terraform.tfvars" only
```
ami_value = "ami-053b0d53c279acc90"
instance_type_value = "t2.micro"
key_name_value = "my-key-pair"
repo_url_value = "https://github.com/techeazy-consulting/techeazy-devops.git"
repo_dir_name = "techeazy-devops"
java_version_value = "openjdk-21-jdk-headless"
aws_region = "us-east-1"
stop_after_minutes   = 10
s3_bucket_name = "bucket-4254"


# AWS Credentials (for assignment ONLY - highly insecure for production!)
aws_access_key_id     = "your_access_key_id" # Replace with your actual AWS Access Key ID
aws_secret_access_key = "your_secret_access_key_id" # Replace with your actual AWS Secret Access Key
aws_default_region    = "us-east-1" 
aws_output_format     = "json"
```


5.  **Create Terraform Workspaces (Dev/Prod):**

    ```bash
    terraform workspace new dev
    terraform workspace new prod
    ```

6.  **Apply the Configuration for a Specific Stage:**

    *   **For the "Dev" stage:**

        ```bash
        terraform workspace select dev
        terraform apply -var-file="dev.tfvars"
        ```

    *   **For the "Prod" stage:**

        ```bash
        terraform workspace select prod
        terraform apply -var-file="prod.tfvars"
        ```

    Type `yes` when prompted to confirm the deployment.

    You can obtain the public IP address using the following command after the `apply` is complete:

    ```bash
    terraform output public-ip-address
    ```

8.  **Access the application:**

    Once the deployment is complete, Terraform will output the public IP address of the EC2 instance. You can access the running application in your web browser using the following URL:

    ```
    http://<public_ip>:80
    ```
application needs some time to start so wait!!!



**Important:**

*   Customize the values in `dev.tfvars` and `prod.tfvars` to match your desired configurations for each environment.
*   **Specifically, ensure that the `key_name_value` is set to the correct key pair name in your AWS account.**  The default value in `variables.tf` is `new-key.pem`, but this should be overridden in your environment-specific `tfvars` files.

## Cleaning Up Resources

To destroy the deployed resources for a specific stage:

1.  **Select the workspace:**

    ```bash
    terraform workspace select dev  # or prod
    ```

2.  **Destroy the resources:**

    ```bash
    terraform destroy -var-file="dev.tfvars"  # or prod.tfvars
    ```

## `stop_after_minutes` Warning

The `script.sh` file contains a command to shut down the instance after a specified number of minutes.  Be aware of this behavior and adjust the `stop_after_minutes` variable accordingly.  This is for cost-saving purposes as per the assignment requirements.  Consider removing or commenting out this line if you do not want the instance to automatically shut down.
