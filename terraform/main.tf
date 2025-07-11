provider "aws" {
  region = local.config.aws_region
}

# IAM Role: S3 Creator/Uploader (Write Only)
resource "aws_iam_role" "s3_creator_uploader_role" {
  name = "s3_creator_uploader_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "S3CreatorUploaderRole-${var.stage}"
  }
}

resource "aws_iam_policy" "s3_creator_uploader_policy" {
  name        = "s3_creator_uploader_policy"
  description = "Provides permissions to create S3 buckets and upload objects, explicitly denying read/download"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "*"
      },
      {
        Effect   = "Deny",
        Action   = ["s3:Get*", "s3:List*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_creator_uploader_attachment" {
  role       = aws_iam_role.s3_creator_uploader_role.name
  policy_arn = aws_iam_policy.s3_creator_uploader_policy.arn
}


resource "aws_iam_instance_profile" "s3_creator_uploader_profile" {
  name_prefix = "s3-creator-uploader-profile"
  role        = aws_iam_role.s3_creator_uploader_role.name

  tags = {
    Name = "S3CreatorUploaderInstanceProfile-${var.stage}"
  }
}

# IAM Role: Read-Only
resource "aws_iam_role" "s3_read_only_role" {
  name = "s3_read_only_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_read_only_policy" {
  name = "s3_read_only_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "read_only_attach" {
  role       = aws_iam_role.s3_read_only_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

resource "aws_iam_instance_profile" "read_only_instance_profile" {
  name = "readonly-ec2-profile-${var.stage}"
  role = aws_iam_role.s3_read_only_role.name
}

# S3 Bucket (private)
resource "aws_s3_bucket" "example" {
  bucket = local.config.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = "My S3 Bucket"
    Environment = var.stage
  }
}

# Lifecycle Rule
resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    id     = "delete_logs_after_7_days"
    status = "Enabled"

    filter {
      prefix = "app/logs/"
    }

    expiration {
      days = 7
    }
  }
}

# Security Group
resource "aws_security_group" "mysg" {
  name = "webig"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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
    Name = "WebSG-${var.stage}"
  }
}

# EC2 Instance with log upload automation
resource "aws_instance" "example1" {
  ami                    = local.config.ami_value
  instance_type          = local.config.instance_type_value
  vpc_security_group_ids = [aws_security_group.mysg.id]
  iam_instance_profile   = aws_iam_instance_profile.s3_creator_uploader_profile.name

  user_data_base64 = base64encode(templatefile("./${var.stage}_script.sh", {
    REPO_URL              = local.config.git_repo_path,
    JAVA_VERSION          = local.config.java_version_value,
    REPO_DIR_NAME         = local.config.repo_dir_name,
    STOP_INSTANCE         = local.config.stop_after_minutes,
    S3_BUCKET_NAME        = local.config.s3_bucket_name,
    AWS_REGION_FOR_SCRIPT = local.config.aws_region,
    GITHUB_TOKEN          = var.github_token,
    GIT_REPO_PATH         = local.config.git_repo_path
  }))

  tags = {
    Name = "MyInstance-${var.stage}"
  }

  depends_on = [aws_s3_bucket.example]
}

# ReadOnly EC2 Instance and list the S3 bucket content
resource "aws_instance" "readonly_ec2" {
  count         = var.enable_readonly_ec2 ? 1 : 0
  ami           = local.config.ami_value
  instance_type = local.config.instance_type_value
  key_name      = local.config.key_name_value

  iam_instance_profile = aws_iam_instance_profile.read_only_instance_profile.name

  user_data = base64encode(templatefile("${path.module}/readonly_script.sh", {
    BUCKET_NAME           = local.config.s3_bucket_name,
    AWS_REGION_FOR_SCRIPT = local.config.aws_region
  }))

  tags = {
    Name = "readonly-ec2-${var.stage}"
  }

  vpc_security_group_ids = [aws_security_group.mysg.id]
}


