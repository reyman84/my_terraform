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

module "vpc" {
  source         = "./modules/vpc"
  region         = var.region
  zone           = var.zone
  vpc_id         = module.vpc.vpc_id
  vpc_cidr       = var.vpc_cidr
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
  ami            = var.ami
  instance_count = var.instance_count
  trusted_ip     = var.trusted_ip
}

/*module "bastion_host" {
  source         = "./modules/bastion_host"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_ids["1a"]
  ami            = data.aws_ami.linux.id
  instance_count = 1
  trusted_ip     = var.trusted_ip
}

module "jenkins_master" {
  source         = "./modules/jenkins/master"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_ids["1b"]
  bastion_sg_id  = module.bastion_host.bastion_sg_id
  nexus_sg_id    = module.nexus.nexus_sg_id
  instance_count = 1
  ami            = var.ami["jenkins_master"]
  trusted_ip     = var.trusted_ip
}

module "jenkins_slave" {
  source            = "./modules/jenkins/slave"
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnet_ids["1c"]
  bastion_sg_id     = module.bastion_host.bastion_sg_id
  ssh_bastion_sg_id = module.bastion_host.ssh_bastion_sg_id
  ami               = data.aws_ami.linux.id
  instance_count    = 1
  trusted_ip        = var.trusted_ip
}

module "ansible_CM" {
  source         = "./modules/ansible/controller"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_ids["1a"]
  bastion_sg_id  = module.bastion_host.bastion_sg_id
  ami            = data.aws_ami.ubuntu.id
  instance_count = 1
  trusted_ip     = var.trusted_ip
}

module "ansible_hosts" {
  source            = "./modules/ansible/hosts"
  vpc_id            = module.vpc.vpc_id
  bastion_sg_id     = module.bastion_host.bastion_sg_id
  ssh_bastion_sg_id = module.bastion_host.ssh_bastion_sg_id
  ansible_hosts_config = {
    amazon_linux = {
      ami       = data.aws_ami.linux.id
      subnet_id = module.vpc.public_subnet_ids["1a"]
    },
    ubuntu = {
      ami       = data.aws_ami.ubuntu.id
      subnet_id = module.vpc.public_subnet_ids["1b"]
    }
  }
  instance_count = 2
  trusted_ip     = var.trusted_ip
}

module "docker" {
  source         = "./modules/docker"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_ids["1b"]
  bastion_sg_id  = module.bastion_host.bastion_sg_id
  ami            = data.aws_ami.linux.id
  instance_count = 1
  trusted_ip     = var.trusted_ip
  key_pair_name  = module.bastion_host.bastion_key_pair_name
}

module "nexus" {
  source               = "./modules/nexus"
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.public_subnet_ids["1c"]
  bastion_sg_id        = module.bastion_host.bastion_sg_id
  jenkins_master_sg_id = module.jenkins_master.jenkins_master_sg_id
  ami                  = var.ami["nexus"]
  instance_count       = 1
  trusted_ip           = var.trusted_ip
  key_pair_name        = module.bastion_host.bastion_key_pair_name
}*/