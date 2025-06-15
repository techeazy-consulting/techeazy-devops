terraform {
  backend "s3" {
    bucket         = var.s3_bucket_name
    key            = "terraform/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
