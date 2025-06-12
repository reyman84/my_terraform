# Providers
provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6.0"
}

# Backend Configuration

# S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "myterraform-backend2025"

  tags = {
    Name        = "Terraform Backend Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "Terraform_VPC"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "Dev"
  }
}

terraform {
  backend "s3" {
    bucket         = "myterraform-backend2025"
    key            = "Terraform_VPC/backend-report"
    region         = "us-east-1"
    dynamodb_table = "Terraform_VPC"
    encrypt        = true
  }
}

# Fetch latest Ubuntu 24.04 LTS AMI (Noble Numbat) with gp3 and HVM virtualization
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Fetch latest Amazon Linux 2023 AMI with Kernel 6.1 and HVM virtualization
data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.7.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon
}

locals {
  ports = {
    ssh     = 22
    http    = 80
    jenkins = 8080
    nexus   = 8081
  }
}

locals {
  instances = {
    "Host - Amazon_Linux" = data.aws_ami.linux.id
    "Host - Ubuntu"       = data.aws_ami.ubuntu.id
  }
}

locals {
  subnet_id = {
    "Host - Amazon_Linux" = aws_subnet.public["1a"].id
    "Host - Ubuntu"       = aws_subnet.public["1b"].id
  }
}