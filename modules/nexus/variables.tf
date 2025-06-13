# Global Configuration
variable "region" {
  description = "AWS region to deploy resources (e.g., us-east-1)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the Bastion Host security group"
  type        = string
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)"
  type        = string
}

variable "public_subnet" {
  description = "Map of availability zones to public subnet CIDRs"
  type        = map(string)
}

variable "private_subnet" {
  description = "Map of availability zones to private subnet CIDRs"
  type        = map(string)
}

variable "zone" {
  description = "Map of availability zones"
  type        = map(string)
}

# Access & Security
variable "trusted_ip" {
  description = "Your laptop's public IP in CIDR format (e.g., 1.2.3.4/32)"
  type        = string
}

variable "instance_count" {
  type = number
}

variable "subnet_id" {
  description = "Subnet ID for the Bastion Host"
  type        = string
}

variable "ami" {
  description = "AMI ID for the Bastion Host"
  type        = string
}

variable "bastion_sg_id" {
  type = string
}

variable "key_pair_name" {
  description = "Key pair name to SSH into Docker host"
  type        = string
}

variable "jenkins_master_sg_id" {
  description = "Security Group ID of Jenkins Master"
  type        = string
}