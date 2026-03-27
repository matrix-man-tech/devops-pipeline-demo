variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "devops-demo"
}

variable "instance_type" {
  description = "EC2 instance type (VM size)"
  type        = string
  default     = "t2.micro"    # Free tier eligible
}

variable "storage_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}