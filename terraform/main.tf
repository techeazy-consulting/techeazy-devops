provider "aws" {
  region = var.aws_region
}



# -------------------------------------------------------------
# EC2 Instance
# -------------------------------------------------------------
resource "aws_instance" "example1" {
    ami = var.ami_value
    instance_type = var.instance_type_value
    vpc_security_group_ids = [aws_security_group.mysg.id]
    iam_instance_profile   = aws_iam_instance_profile.ec2_combined_profile.name 

    user_data = base64encode(templatefile("./config/${var.stage}_script.sh", {
    REPO_URL            = var.repo_url_value
    JAVA_VERSION        = var.java_version_value # Match JAVA_VERSION in script
    REPO_DIR_NAME       = var.repo_dir_name    # Match REPO_DIR_NAME in script
    STOP_INSTANCE       = var.stop_after_minutes # Match STOP_INSTANCE in script
    S3_BUCKET_NAME      = var.s3_bucket_name     # Match S3_BUCKET_NAME in script
    AWS_REGION_FOR_SCRIPT = var.aws_region       # NEW: Pass the AWS region from your provider config
#    GITHUB_TOKEN  = var.github_token
    GIT_REPO_PATH = var.git_repo_path
    CW_AGENT_CONFIG_JSON = templatefile("./config.json.tpl", {
        log_file_path      = var.app_log_file_path         // <-- Now truly a variable!
        log_group_name_var = aws_cloudwatch_log_group.app_log_group.name
    })
  }))

  tags = {
    Name = "MyInstance-${var.stage}"
  }

  depends_on = [
    aws_s3_bucket.example
  ]
}



# -------------------------------------------------------------
# Security Group
# -------------------------------------------------------------
resource "aws_security_group" "mysg" {
  name = "webig-${var.stage}"

  ingress {
    description = "HTTP from vpc"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
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
    Name = "Web.sg-${var.stage}"
  }

  
}

resource "aws_s3_bucket" "example" {
  bucket = "${var.s3_bucket_name}-${var.stage}"

  force_destroy = true 

  lifecycle_rule {
    enabled = true

    expiration {
      days = 7
    }

    prefix = "logs/${var.stage}/"
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}






# -------------------------------------------------------------
# SNS Topic
# -------------------------------------------------------------
resource "aws_sns_topic" "app_alerts_topic" {
  name         = "app-alerts-topic-${var.stage}" # Added stage to name for uniqueness
  display_name = "Application Alerts"
  tags = {
    Assignment = "DevOps_5th"
    ManagedBy  = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.app_alerts_topic.arn
  protocol  = "email"
  endpoint  = var.email_address # <--- **REPLACE THIS WITH YOUR EMAIL ADDRESS**
}

output "sns_topic_arn" {
  description = "The ARN of the newly created SNS topic."
  value       = aws_sns_topic.app_alerts_topic.arn
}

# -----------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP & METRIC FILTER
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "app.log-${var.stage}" # Added stage for uniqueness
  retention_in_days = 7
}

resource "aws_cloudwatch_log_metric_filter" "error_metric_filter" {
  name           = "ErrorMetricFilter-${var.stage}" # Added stage for uniqueness
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
  pattern        = "ERROR" 

  metric_transformation {
    name      = "ErrorCount"
    namespace = "MyApp/Logs"
    value     = "1"
  }
}

# -----------------------------------------------------------------------------
# CLOUDWATCH METRIC ALARM (for log errors)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name                = "AppLogErrorAlarm-${var.stage}" # Added stage for uniqueness
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  statistic                 = "Sum"
  threshold                 = 1   # Trigger if at least 1 error in the period
  period                    = 300 # 5 minutes in seconds
  metric_name               = aws_cloudwatch_log_metric_filter.error_metric_filter.metric_transformation[0].name
  namespace                 = aws_cloudwatch_log_metric_filter.error_metric_filter.metric_transformation[0].namespace
  alarm_description         = "Triggers when application logs contain errors."
  alarm_actions             = [aws_sns_topic.app_alerts_topic.arn]
  ok_actions                = [aws_sns_topic.app_alerts_topic.arn]
  treat_missing_data        = "notBreaching"
}

# -----------------------------------------------------------------------------
# CLOUDWATCH METRIC ALARM (for EC2 Instance Health Check Failure)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "instance_health_alarm" {
  alarm_name                = "EC2InstanceHealthCheckFailed-${var.stage}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2 # Check over 2 periods
  datapoints_to_alarm       = 2 # 2 consecutive failures
  statistic                 = "Minimum" # If the minimum is 0, it means it passed. If it's 1, it failed.
  threshold                 = 1
  period                    = 60 # 1 minute period
  metric_name               = "StatusCheckFailed_System" # Or "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  dimensions = {
    InstanceId = aws_instance.example1.id
  }
  alarm_description         = "Triggers when the EC2 instance fails system status checks."
  alarm_actions             = [aws_sns_topic.app_alerts_topic.arn]
  ok_actions                = [aws_sns_topic.app_alerts_topic.arn]
  treat_missing_data        = "breaching" # If instance stops reporting, it's a failure
}

# -----------------------------------------------------------------------------
# CLOUDWATCH METRIC ALARM (for Memory Utilization)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm" {
  alarm_name                = "EC2MemoryUtilizationHigh-${var.stage}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 3 # Check over 3 periods
  datapoints_to_alarm       = 3 # 3 consecutive minutes of high usage
  statistic                 = "Average"
  threshold                 = 85 # 85% memory utilization
  period                    = 60 # 1 minute period
  metric_name               = "mem_used_percent" # Metric name from CloudWatch Agent config
  namespace                 = "CWAgent"          # Namespace from CloudWatch Agent config
  dimensions = {
    InstanceId = aws_instance.example1.id
  }
  alarm_description         = "Triggers when EC2 instance memory utilization is consistently high."
  alarm_actions             = [aws_sns_topic.app_alerts_topic.arn]
  ok_actions                = [aws_sns_topic.app_alerts_topic.arn]
  treat_missing_data        = "breaching"
}

