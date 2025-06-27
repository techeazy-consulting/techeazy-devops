terraform {
  backend "s3" {
    bucket         = var.backup_bucket_name        #"your-terraform-state-bucket"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
