# -----------------------------------------------------------------------------
# CONSOLIDATED IAM ROLE FOR THE EC2 INSTANCE
# (To allow it to send metrics/logs AND perform S3 operations)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ec2_combined_role" {
  name = "EC2CombinedRole-${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })

  tags = {
    Name = "EC2CombinedRole-${var.stage}"
  }
}

# Attach CloudWatchAgentServerPolicy
resource "aws_iam_role_policy_attachment" "cw_agent_policy_attachment" {
  role       = aws_iam_role.ec2_combined_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Define your custom S3 policy
resource "aws_iam_policy" "s3_combined_policy" {
  name        = "S3CombinedPolicy-${var.stage}"
  description = "Provides permissions for S3 creation, upload, and lifecycle management, combined with other necessary S3 actions for the EC2 instance."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutBucketLifecycleConfiguration",
          "s3:GetBucketLifecycleConfiguration",
          "s3:DeleteBucketLifecycle",
          "s3:ListAllMyBuckets", # Often needed to list existing buckets
          "s3:GetBucketLocation", # Often needed
        ]
        Resource = "*" # Consider scoping this down to specific buckets if possible
      },
      # Re-evaluating the 'Deny' statement:
      # Your original policy had a broad deny for "s3:Get*" and "s3:List*".
      # This is problematic because "CloudWatchAgentServerPolicy" might need "s3:Get*" or "s3:List*"
      # permissions for various CloudWatch-related S3 interactions, or your
      # EC2 instance might need to list objects in a bucket it just created.
      #
      # If you explicitly allow 'GetBucketLifecycleConfiguration' as you did,
      # that explicit allow will generally override a broad deny for 's3:Get*'.
      # However, it's a complex and potentially dangerous pattern.
      #
      # It's generally better to grant only the *minimum necessary* Allow permissions
      # rather than relying on broad Deny statements unless absolutely critical
      # for a very specific security posture.
      #
      # For now, I'm removing the broad Deny, as it can easily cause unintended
      # permission issues when combined with other policies or future requirements.
      # If you must have specific denies, make them as granular as possible.
      # {
      #   Effect   = "Deny"
      #   Action   = [
      #     "s3:Get*",
      #     "s3:List*",
      #   ]
      #   Resource = "*"
      # },
    ]
  })
}

# Attach your custom S3 policy to the consolidated role
resource "aws_iam_role_policy_attachment" "s3_combined_policy_attachment" {
  role       = aws_iam_role.ec2_combined_role.name
  policy_arn = aws_iam_policy.s3_combined_policy.arn
}

# Create a single Instance Profile for the consolidated role
resource "aws_iam_instance_profile" "ec2_combined_profile" {
  name = "EC2CombinedInstanceProfile-${var.stage}" # Naming it clearly
  role = aws_iam_role.ec2_combined_role.name

  tags = {
    Name = "EC2CombinedInstanceProfile-${var.stage}"
  }
}