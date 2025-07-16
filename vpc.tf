# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.VPC_NAME
  cidr = var.VpcCIDR

  azs             = [var.Zone1, var.Zone2, var.Zone3]
  #private_subnets = [var.PrivSub1CIDR, var.PrivSub2CIDR, var.PrivSub3CIDR]
  public_subnets  = [var.PubSub1CIDR, var.PubSub2CIDR, var.PubSub3CIDR]

  #enable_nat_gateway      = true
  #single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  tags = {
    Name    = var.VPC_NAME
    Project = var.PROJECT
  }
}

###############
## Key-Pairs ##
###############

# --------------------- Baston Host --------------------- #
resource "aws_key_pair" "devops-project" {
  key_name   = "devops-project"
  public_key = file("key-files/devops-project.pub")
}

# --------------------- Web Server --------------------- #
/*resource "aws_key_pair" "web01" {
  key_name   = "web-host"
  public_key = file("key-files/web01.pub")
}

# --------------------- Ansible --------------------- #
resource "aws_key_pair" "ansible" {
  key_name   = "ansible"
  public_key = file("key-files/ansible.pub")
}*/