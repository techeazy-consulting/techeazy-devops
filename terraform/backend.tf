terraform {
  backend "s3" {
    bucket         = "sumit-4254"        #"your-terraform-state-bucket"
    key            = "terraform/terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
