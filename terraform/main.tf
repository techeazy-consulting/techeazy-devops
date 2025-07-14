


provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "instance1" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    key_name = var.key_name
    security_groups = [var.security_group_id]
    user_data = templatefile("${path.module}/user_data.tmpl.sh", {
    bucket_name = var.bucket_name
  })

    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

    tags = {
        Name = "techeazy-instance"
        Stage = var.stage
    }
  
}


#IAM Role 1: Read only S-3

resource "aws_iam_role" "s3_readonly_role" {
    name = "s3_readonly_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {Service = "ec2.amazonaws.com"},
            Action = "sts:AssumeRole"
        }]
    })
  
}

resource "aws_iam_policy" "s3_readonly_policy" {
    name = "s3-readonly-policy"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = ["s3:ListBucket","s3:GetObject"]
            Effect = "Allow",
            Resource = "*"
        }]
    }) 
}

resource "aws_iam_role_policy_attachment" "readonly_attach" {
    role = aws_iam_role.s3_readonly_role.name
    policy_arn = aws_iam_policy.s3_readonly_policy.arn
  
}

#IAM Role 2:Write only S3

resource "aws_iam_role" "s3_writeonly_role" {
    name = "s3-writeonly-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {Service = "ec2.amazonaws.com"}
            Action = "sts:AssumeRole"
        }]
    })
  
}

resource "aws_iam_policy" "s3_writeonly_policy" {
    name = "s3-writeonly-policy"
    policy = jsonencode({
        Version  ="2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = ["s3:PutObject","s3:CreateBucket"]
                Resource = "*"

            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "writeonly_attach" {
    role = aws_iam_role.s3_writeonly_role.name
    policy_arn = aws_iam_policy.s3_writeonly_policy.arn
  
}

#Instace profile for EC2

resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2-s3-writeonly-profile"
    role = aws_iam_role.s3_writeonly_role.name
  
}

#S3 bucket creation

resource "aws_s3_bucket" "private_logs_bucket" {
    bucket = var.bucket_name
    force_destroy = true

    tags = {
      Name = "Private App Logs Bucket"
    }
  
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.private_logs_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_rule" {
    bucket = aws_s3_bucket.private_logs_bucket.id

    rule {
      id = "delete-logs"
      status = "Enabled"

      expiration {
        days = 7
      }

      filter {
        prefix = ""
      }
    }
  
}

resource "aws_iam_instance_profile" "readonly_profile" {
    name = "ec2-readonly-profile"
    role = aws_iam_role.s3_readonly_role.name
  
}

#Second ec2 instamce with read only

resource "aws_instance" "readonly_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  security_groups = [var.security_group_id]
  iam_instance_profile = aws_iam_instance_profile.readonly_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y aws-cli

              echo "Listing logs from S3..." > /home/ec2-user/readonly_check.log
              aws s3 ls s3://${var.bucket_name}/app/logs/ >> /home/ec2-user/readonly_check.log
              aws s3 ls s3://${var.bucket_name}/system/ >> /home/ec2-user/readonly_check.log
              EOF

  tags = {
    Name = "techeazy-readonly-instance"
    Stage = var.stage
  }   
}         