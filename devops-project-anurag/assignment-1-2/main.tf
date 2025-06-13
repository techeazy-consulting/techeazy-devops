# Launch EC2 instance with IAM role and user_data
provider "aws" {
  region = var.region
}

resource "aws_instance" "devops_ec2" {
  ami                    = "ami-0f918f7e67a3323f0"
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data              = file("user_data.sh")

  tags = {
    Name  = "DevOps-${var.stage}-EC2"
    Stage = var.stage
  }
}
