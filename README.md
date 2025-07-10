# 🚀 Techeazy DevOps Deployment Guide

Easily deploy a **Spring Boot** app on **AWS EC2** using **Terraform**!  
✅ Uses **Java 21**  
✅ Runs on **port 80**  
✅ Stores logs in a **private S3 bucket** with **auto-deletion after 7 days**  
✅ Secure with **IAM roles**

---

## 🛠️ Prerequisites

Make sure you have the following ready:

- ✅ [Terraform](https://www.terraform.io/downloads) installed  
- ✅ AWS CLI configured (`aws configure`)  
- ✅ An EC2 Key Pair  
- ✅ A `.tfvars` file (e.g., `dev.tfvars`) with your specific values  

---

# 🚀 Techeazy DevOps Deployment Guide

Easily deploy a **Spring Boot** app on **AWS EC2** using **Terraform**!  
✅ **Java 21**  
✅ **Port 80**  
✅ **Private S3 bucket** for logs with **auto-deletion after 7 days**  
✅ **IAM roles** for security  

---

## 🛠️ Prerequisites

Make sure you have the following ready:  

- 🛠️ [Terraform](https://www.terraform.io/downloads) installed  
- 🛠️ AWS CLI configured (`aws configure`)  
- 🛠️ An EC2 Key Pair  
- 🛠️ A `.tfvars` file (e.g., `dev.tfvars`) with your specific values  

---

## 🚀 Deployment Steps

Follow these steps to deploy the application:  

### 1️⃣ **Initialize Terraform**  
Run the following command to initialize Terraform:  
```bash
terraform init
```

### 2️⃣ **Preview the Plan**  
Generate and review the execution plan:  
```bash
terraform plan -var-file="dev.tfvars"
```

### 3️⃣ **Apply the Deployment**  
Deploy the infrastructure:  
```bash
terraform apply -var-file="dev.tfvars"
```

### 4️⃣ **Access the Application**  
Once deployed, access the app in your browser using the public IP provided in the Terraform output:  

http://<public-ip>


### 5️⃣ **Verify Deployment**  
You should see the message:  

App Deployed Successfully 🎉


---

## 📜 Log Storage Info

### ✅ **Application Logs**  
- **Location:** `s3://<your-bucket-name>/app/logs/`  
- **Source:** `/home/ec2-user/app.log`  

### ✅ **System Logs**  
- **Location:** `s3://<your-bucket-name>/system/`  
- **Source:** `/var/log/cloud-init.log`  

### 🔎 **How to Check Logs**  
1. Open AWS Console  
2. Navigate to **S3**  
3. Browse to your bucket  
4. Check the `app/logs/` or `system/` folders  

## 🗑️ **Auto-Cleanup**  
Logs are auto-deleted after 7 days using a lifecycle policy.  

---

### 🔐 IAM Roles

### **Read-Only Role:** `s3_readonly_role`  
- **Permissions:**  
    - `s3:ListBucket`  
    - `s3:GetObject`  

### **Write-Only Role:** `s3_writeonly_role`  
- **Permissions:**  
    - `s3:PutObject`  
    - `s3:CreateBucket`  

ℹ️ **Note:** This role is attached to the EC2 instance for securely writing logs.  

---

### 🧹 Clean-Up

To remove all resources:  

1. **Empty your S3 bucket** via AWS Console  
2. **Destroy infrastructure** with Terraform:  
```bash
terraform destroy -var-file="dev.tfvars"
```

---  

# trigger
