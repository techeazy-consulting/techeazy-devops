variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "EC2 Key Pair"
  type        = string
}

variable "stage" {
  default = "dev"
}

variable "bucket_name" {
  description = "Log bucket name"
  type        = string
}

variable "region" {
  default = "ap-south-1"
}
