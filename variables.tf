# Global Configuration
variable "region" {
  description = "AWS region to deploy resources (e.g., us-east-1)"
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

# AMI & Compute Configuration
variable "ami" {
  description = "Mapping of instance roles/types to AMI IDs"
  type        = map(string)
}

variable "instance_count" {
  description = "Mapping of instance types to the number of instances to launch"
  type        = map(number)
}