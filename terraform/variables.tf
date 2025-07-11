variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1" 
}

variable "ami_value" {
    description = "value for the ami"
    type        = string
    default     = "ami-053b0d53c279acc90" 
}

variable "instance_type_value" {
    description = "value for instance_type"
    type        = string
    default     = "t2.micro"
}

variable "java_version_value" {
    description = "java installation version"
    type        = string
    default     = "openjdk-21-jdk-headless"
}

variable "key_name_value" {
    description = "name of pem file"
    type        = string
    default     = "new-key.pem"
}

variable "repo_url_value" {
    description = "the github url of repository to clone"
    type        = string
    default     = "https://github.com/abhinayakumar130/tech_eazy_devops_abhinayakumar130.git"
}

variable "repo_dir_name" {
    description = "the directory name of the repository to clone"
    type        = string
    default     = "tech_eazy_devops_abhinayakumar130"
}

variable "stage" {
    description = "The stage of the deployment (e.g., dev, prod)."
    type        = string
    default     = "dev"  
}

variable "s3_bucket_name" {
  description = "Default AWS region for CLI configuration"
  type        = string
  default     = "bucket-4254" # Replace with your desired bucket name
}

variable "stop_after_minutes" {
    description = "The number of minutes after which the instance should stop."
    type        = number
    default     = 5
}

variable "github_token" {
  description = "GitHub token for accessing private repositories"
  type        = string
  sensitive = true  
}

variable "git_repo_path" {
  description = "Path to the Git repository"
  type        = string
  default     = "https://github.com/abhinayakumar130/tech_eazy_devops_abhinayakumar130.git" # Replace with your actual Git repository path
}

variable "enable_readonly_ec2" {
  type    = bool
  default = false
}

