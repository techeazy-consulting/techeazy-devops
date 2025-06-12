provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "example1" {
    ami = var.ami_value
    instance_type = var.instance_type_value
    vpc_security_group_ids = [aws_security_group.mysg.id]
    iam_instance_profile   = aws_iam_instance_profile.s3_creator_uploader_profile.name # Attach the instance profile
    user_data = base64encode(templatefile("./script.sh", {
    repo_url     = var.repo_url_value
    java_version = var.java_version_value
    repo_dir_name= var.repo_dir_name
    stop_after_minutes = var.stop_after_minutes
    # Pass the AWS credentials to the user_data script
    aws_access_key_id    = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key
    aws_default_region   = var.aws_default_region
    aws_output_format    = var.aws_output_format
    s3_bucket_name = var.s3_bucket_name
  }))
  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("~/.ssh/id_rsa")  # Replace with the path to your private key
    host        = self.public_ip
  }
}



resource "aws_security_group" "mysg" {
  name = "webig"

  ingress {
    description = "HTTP from vpc"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Web.sg"
  }

  
}

resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name # Use the variable for the bucket name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    id     = "delete_app_logs_after_7_days"
    status = "Enabled"

    filter {
      prefix = "app/logs/"
    }

    expiration {
      days = 7
    }
  }
}

# --- IAM Role for Read-Only S3 Access ---
resource "aws_iam_role" "s3_read_only_role" {
  name = "s3_read_only_access_role"

  # Defines who can assume this role. Here, EC2 instances can assume it.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com" # Allows EC2 instances to assume this role. Adjust as needed.
        }
      },
    ]
  })

  tags = {
    Name = "S3ReadOnlyRole"
  }
}

# IAM Policy for Read-Only S3 Access
resource "aws_iam_policy" "s3_read_only_policy" {
  name        = "s3_read_only_policy"
  description = "Provides read-only access to S3 buckets and objects"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:Get*",  # Allows GetObject, GetBucketLocation, etc.
          "s3:List*", # Allows ListBucket, ListAllMyBuckets, etc.
        ]
        Resource = "*" # Apply to all S3 resources
      },
    ]
  })
}

# Attach Read-Only S3 Policy to the Role
resource "aws_iam_role_policy_attachment" "s3_read_only_attachment" {
  role       = aws_iam_role.s3_read_only_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

# --- IAM Role for S3 Bucket Creation and File Upload (No Read/Download) ---
resource "aws_iam_role" "s3_creator_uploader_role" {
  name = "s3_creator_uploader_access_role"

  # Defines who can assume this role. Here, EC2 instances can assume it.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com" # Allows EC2 instances to assume this role. Adjust as needed.
        }
      },
    ]
  })

  tags = {
    Name = "S3CreatorUploaderRole"
  }
}

# IAM Policy for S3 Bucket Creation and File Upload (Explicitly No Read/Download)
resource "aws_iam_policy" "s3_creator_uploader_policy" {
  name        = "s3_creator_uploader_policy"
  description = "Provides permissions to create S3 buckets and upload objects, explicitly denying read/download"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:CreateBucket", # Allows creating new buckets
          "s3:PutObject",    # Allows uploading objects
          "s3:PutObjectAcl", # Allows setting ACLs on uploaded objects (often needed with PutObject)
        ]
        Resource = "*" # Apply to all S3 resources
      },
      {
        Effect   = "Deny"     # Explicitly deny read and list actions
        Action   = [
          "s3:Get*",  # Denies GetObject, GetBucketLocation, etc.
          "s3:List*", # Denies ListBucket, ListAllMyBuckets, etc.
        ]
        Resource = "*" # Apply to all S3 resources
      },
    ]
  })
}

# Attach S3 Creator/Uploader Policy to the Role
resource "aws_iam_role_policy_attachment" "s3_creator_uploader_attachment" {
  role       = aws_iam_role.s3_creator_uploader_role.name
  policy_arn = aws_iam_policy.s3_creator_uploader_policy.arn
}

# --- IAM Instance Profile for S3 Creator/Uploader Role ---
# An instance profile is required to attach an IAM role to an EC2 instance.
resource "aws_iam_instance_profile" "s3_creator_uploader_profile" {
  name = "s3_creator_uploader_instance_profile"
  role = aws_iam_role.s3_creator_uploader_role.name # Reference the role created above

  tags = {
    Name = "S3CreatorUploaderInstanceProfile"
  }
}