# EC2 Instance Deployment with Terraform (Dev/Prod Stages)

This project automates the deployment of an EC2 instance, configures it with Java and Maven, clones a specified Git repository, and runs a Spring Boot application. It supports separate "Dev" and "Prod" stages with different configurations using Terraform workspaces.

## Prerequisites

Before you begin, ensure you have the following:

*   AWS CLI and Terraform installed


## Steps to Run the Application

1.  **Clone the repository:**

    ```bash
    git clone <repository-url>
    cd <project-directory>
    ```

2.  **Configure AWS Credentials:**

    ```bash
    aws configure
    ```

    Follow the prompts to enter your AWS Access Key ID, Secret Access Key, region, and output format.  **Important:** Do *not* hardcode credentials in the repository.

3.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

4.  **Generate an SSH Key Pair (if you don't have one):**

    If you don't already have an SSH key pair, you can generate one using the following command:

    ```bash
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
    ```

    This will create a private key (`~/.ssh/id_rsa`) and a public key (`~/.ssh/id_rsa.pub`).  **Important:**  Keep the private key secure.  You will need it to connect to the EC2 instance.  The public key will       be associated with the instance via the `key_name_value` variable.


5.  **Create Terraform Workspaces (Dev/Prod):**

    ```bash
    terraform workspace new dev
    terraform workspace new prod
    ```

6.  **Apply the Configuration for a Specific Stage:**

    *   **For the "Dev" stage:**

        ```bash
        terraform workspace select dev
        terraform apply -var-file="modules/dev.tfvars"
        ```

    *   **For the "Prod" stage:**

        ```bash
        terraform workspace select prod
        terraform apply -var-file="modules/prod.tfvars"
        ```

    Type `yes` when prompted to confirm the deployment.

7.  **Access the application:**

    Once the deployment is complete, Terraform will output the public IP address of the EC2 instance. You can access the running application in your web browser using the following URL:

    ```
    http://<public_ip>:80
    ```

    You can obtain the public IP address using the following command after the `apply` is complete:

    ```bash
    terraform output public-ip-address
    ```


**Important:**

*   Customize the values in `modules/dev.tfvars` and `modules/prod.tfvars` to match your desired configurations for each environment.
*   **Specifically, ensure that the `key_name_value` is set to the correct key pair name in your AWS account.**  The default value in `modules/variables.tf` is `new-key.pem`, but this should be overridden in your environment-specific `tfvars` files.

## Cleaning Up Resources

To destroy the deployed resources for a specific stage:

1.  **Select the workspace:**

    ```bash
    terraform workspace select dev  # or prod
    ```

2.  **Destroy the resources:**

    ```bash
    terraform destroy -var-file="modules/dev.tfvars"  # or modules/prod.tfvars
    ```

## `stop_after_minutes` Warning

The `modules/script.sh` file contains a command to shut down the instance after a specified number of minutes.  Be aware of this behavior and adjust the `stop_after_minutes` variable accordingly.  This is for cost-saving purposes as per the assignment requirements.  Consider removing or commenting out this line if you do not want the instance to automatically shut down.
