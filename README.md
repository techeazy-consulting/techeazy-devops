# 🚀 Techeazy DevOps Deployment - Assignment 4

Welcome to the **Automated EC2 Deployment via Terraform & GitHub Actions** project!  
This project showcases a full pipeline that supports multi-stage (🛠 dev, 🚨 prod) deployments, private/public repo logic, S3 log uploads, and health checks — all powered by **Terraform**, **GitHub Actions**, and **EC2** 💻☁️.

---

## 🌟 Assignment Objectives ✅

### 🔁 Parameterized Multi-Stage Deployment
- Supports `dev` and `prod` stages 🧪🛡
- Dynamically handles configuration and environment separation
- Selectable via:
  - `workflow_dispatch` dropdown 🔽
  - Branch/tag-based deployment triggers

### 🧩 Config Separation
- Stage-based config files (`dev.json`, `prod.json`)
- Runtime config copied and loaded into your Spring Boot app on EC2 🔧

### 🔐 Private/Public GitHub Config Handling
- **Public repo** clone used in `dev` stage ✅
- **Private repo** clone using token in `prod` stage 🔒
- Token securely passed from GitHub Secrets 🔑

### 📦 GitHub Token Handling
- `REPO_ACCESS_TOKEN` stored securely in `GitHub Secrets`
- Used only in `prod` when accessing private repo ✅

### ☁️ Stage-Based S3 Log Upload
- Logs are uploaded to:
  - `s3://your-bucket/logs/dev/app.log`
  - `s3://your-bucket/logs/prod/app.log`
- Cloud-init logs are also uploaded 🚀

### 🩺 Post-Deployment Health Check
- Automated health check via `curl` on EC2 Public IP 🌐
- Verifies that the Spring Boot app is running properly ✔️

---

## ⚙️ GitHub Secrets Required

To run this workflow securely, you must define the following **Secrets** in your GitHub repo:

| 🔐 Secret Name           | 📝 Description                                                                 |
|--------------------------|---------------------------------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`      | Your AWS IAM Access Key ID                                                      |
| `AWS_SECRET_ACCESS_KEY`  | Your AWS IAM Secret Access Key                                                  |
| `REPO_ACCESS_TOKEN`      | Personal Access Token (PAT) to access **private** GitHub repo for `prod` stage |
| `INSTANCE_KEY`           | Your EC2 PEM key content (used for SSH login to instance)                       |

---

## 🚦 How It Works

1. 🧾 **Triggering the Workflow:**
   - ✅ Manually trigger from the **Actions tab** using the `Run workflow` button and choose the `stage` (`dev` or `prod`)
   - ⚠️ **Do not rely on auto-trigger via push** unless you configure default `stage` handling inside the code (manual trigger is safest)
   - Tags like `deploy-dev` or `deploy-prod` can trigger, but only if predefined inputs are handled
   - 💡 **Best Practice:** Always manually trigger for clean stage separation


2. 🛠 **Terraform Handles:**
   - EC2 provisioning with correct tags
   - S3 backend and bucket for logs
   - Parameterized `.tfvars` for stage

3. 💻 **GitHub Action Workflow:**
   - Sets environment vars like `STAGE`
   - Retrieves EC2 public IP
   - Clones correct repo (public for dev / private for prod)
   - Executes `deploy.sh` to build and run app
   - Uploads logs to stage-specific S3 path
   - Performs `curl`-based health check 🔍

4. ☁️ **Logs Uploaded To S3:**
   - Application log `app.log`
   - Cloud-init log `cloud-init.log`

---

## 📂 No Local File Structure Used

This project uses:
- `terraform/` directory for infrastructure code
- `scripts/deploy.sh` for deployment logic
- `.github/workflows/` for GitHub Actions CI/CD

Everything is modular and stage-aware 🎯

---

## 📌 Tech Stack

- ☁️ **AWS EC2 & S3**
- ⚙️ **Terraform**
- 🧪 **Spring Boot + Maven**
- 🤖 **GitHub Actions**
- 🔐 **GitHub Secrets**

---

## ✅ Final Notes

- Make sure your repo is **public** for `dev`, and **private** for `prod`
- Secrets must be added **before running the workflow**
- You can view deployment logs in both:
  - GitHub Actions UI
  - S3 bucket (organized by stage)

---

