variable "instance_type" {
    description = "type of ec2 instance"
    type = string
    default = "t2.micro"
  
}

variable "ami_id" {
    description = "value of ami id"
    type = string
  
}

variable "subnet_id" {
    description = "value of subnet id"
    type = string
  
}

variable "key_name" {
    description = "value of existing keypair"
    type = string
  
}


variable "security_group_id" {
    description = "security grp id"
  
}

variable "repo_url" {
    description = "url of git repo"
    type = string
    default = "https://github.com/techeazy-consulting/techeazy-devops.git"
  
}

variable "stage" {
    description = "environment stage(eg. dev,prod)"
    type = string
    default = "dev"
  
}

variable "bucket_name" {
    description = "bucket name"
    type = string 
}