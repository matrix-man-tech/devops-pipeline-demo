terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ── Provider ─────────────────────────────────────────────────
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    # Add other services like vpc, iam, etc. if needed
  }
}

# ── Networking ───────────────────────────────────────────────

# VPC = your private network in the cloud
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"   # IP range for your network
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.environment
  }
}

# Subnet = a subdivision of your VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet"
    Environment = var.environment
  }
}

# Internet Gateway = allows your VPC to reach the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.environment
  }
}

# Route Table = rules for where network traffic goes
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                        # All traffic
    gateway_id = aws_internet_gateway.main.id        # Goes through internet gateway
  }

  tags = {
    Name        = "${var.app_name}-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group = firewall rules
resource "aws_security_group" "app" {
  name        = "${var.app_name}-sg"
  description = "Security group for ${var.app_name}"
  vpc_id      = aws_vpc.main.id

  # Allow incoming HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  # Allow incoming traffic on app port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "App port"
  }

  # Allow SSH for server management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  # Allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  tags = {
    Name        = "${var.app_name}-sg"
    Environment = var.environment
  }
}

# ── Compute (VM) ─────────────────────────────────────────────

resource "aws_instance" "app" {
  ami                    = "ami-0c55b159cbfafe1f0"   # Amazon Linux 2
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]

  root_block_device {
    volume_size = var.storage_size
    volume_type = "gp3"
  }

  # This script runs when the VM first starts — installs Docker and runs your app
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    docker pull node:18-alpine
    docker run -d -p 3000:3000 --name devops-demo \
      --restart unless-stopped \
      -e NODE_ENV=production \
      devops-demo:latest
  EOF

  tags = {
    Name        = "${var.app_name}-server"
    Environment = var.environment
  }
}

# ── Storage ──────────────────────────────────────────────────

# S3 bucket for storing app artifacts (logs, backups, build files)
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.app_name}-artifacts-${var.environment}"

  tags = {
    Name        = "${var.app_name}-artifacts"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"    # Keeps history of every file version
  }
}