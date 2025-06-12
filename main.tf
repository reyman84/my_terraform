# Providers
provider "aws" {
  region = "us-east-1"
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
  subnet_id = {
    "Host - Amazon_Linux" = module.vpc.public_subnet_ids["1a"]
    "Host - Ubuntu"       = module.vpc.public_subnet_ids["1b"]
  }
}


locals {
  ports = {
    ssh     = 22
    http    = 80
    jenkins = 8080
    nexus   = 8081
  }
}

module "vpc" {
  source          = "./modules/vpc"
  region          = var.region
  trusted_ip      = var.trusted_ip
  ami             = var.ami
  instance_count  = var.instance_count
  vpc_cidr        = var.vpc_cidr
  zone            = var.zone
  public_subnet   = var.public_subnet
  private_subnet  = var.private_subnet
}
