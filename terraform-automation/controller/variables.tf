

variable "environment" {
  type        = string
  description = "Environment name (dev or prod)"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "ap-south-1"
}
variable "key_name" {
  type = string
  default = "vinod_jat"
  
}




# variable "my_ip" {
#   description = "Your public IP (x.x.x.x/32)"
#   type        = string
# }

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
