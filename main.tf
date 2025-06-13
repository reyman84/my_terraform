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
  source         = "./modules/vpc"
  vpc_id         = module.vpc.vpc_id
  region         = var.region
  trusted_ip     = var.trusted_ip
  ami            = var.ami
  instance_count = var.instance_count
  vpc_cidr       = var.vpc_cidr
  zone           = var.zone
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
}

module "bastion_host" {
  source         = "./modules/bastion_host"
  instance_count = 1
  zone           = var.zone
  vpc_cidr       = var.vpc_cidr
  region         = var.region
  trusted_ip     = var.trusted_ip
  ami            = data.aws_ami.linux.id
  vpc_id         = module.vpc.vpc_id
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
  subnet_id      = module.vpc.public_subnet_ids["1a"]
}

module "jenkins_master" {
  source         = "./modules/jenkins/master"
  zone           = var.zone
  instance_count = 1
  vpc_cidr       = var.vpc_cidr
  region         = var.region
  trusted_ip     = var.trusted_ip
  ami            = var.ami["jenkins_master"]
  vpc_id         = module.vpc.vpc_id
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
  subnet_id      = module.vpc.public_subnet_ids["1b"]
  bastion_sg_id  = module.bastion_host.bastion_sg_id
}

module "jenkins_slave" {
  source            = "./modules/jenkins/slave"
  zone              = var.zone
  instance_count    = 1
  vpc_cidr          = var.vpc_cidr
  region            = var.region
  trusted_ip        = var.trusted_ip
  ami               = data.aws_ami.linux.id
  vpc_id            = module.vpc.vpc_id
  public_subnet     = var.public_subnet
  private_subnet    = var.private_subnet
  subnet_id         = module.vpc.public_subnet_ids["1c"]
  bastion_sg_id     = module.bastion_host.bastion_sg_id
  ssh_bastion_sg_id = module.bastion_host.ssh_bastion_sg_id
}

module "ansible_CM" {
  source         = "./modules/ansible/controller"
  zone           = var.zone
  instance_count = 1
  vpc_cidr       = var.vpc_cidr
  region         = var.region
  trusted_ip     = var.trusted_ip
  ami            = data.aws_ami.ubuntu.id
  vpc_id         = module.vpc.vpc_id
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
  subnet_id      = module.vpc.public_subnet_ids["1a"]
  bastion_sg_id  = module.bastion_host.bastion_sg_id
}

module "ansible_hosts" {
  source            = "./modules/ansible/hosts"
  zone              = var.zone
  instance_count    = 1
  vpc_cidr          = var.vpc_cidr
  region            = var.region
  trusted_ip        = var.trusted_ip
  ami               = data.aws_ami.linux.id
  vpc_id            = module.vpc.vpc_id
  public_subnet     = var.public_subnet
  private_subnet    = var.private_subnet
  subnet_id         = module.vpc.public_subnet_ids["1c"]
  bastion_sg_id     = module.bastion_host.bastion_sg_id
  ssh_bastion_sg_id = module.bastion_host.ssh_bastion_sg_id
}