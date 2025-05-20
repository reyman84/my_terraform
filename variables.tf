variable "region" {
  description = "Provides the AWS region to implement changes"
}

variable "vpc_cidr" {
  description = "Map of private subnets"
  type        = string
}

variable "trusted_ip" {
  description = "IP address of my Laptop's IP"
}

variable "public_subnet" {
  description = "Map of public subnets"
  type        = map(string)
}

variable "private_subnet" {
  description = "Map of private subnets"
  type        = map(string)
}

variable "zone" {
  description = "Map of zones"
  type        = map(string)
}

variable "ami" {
  description = "AMI value for different types of instances"
  type        = map(string)
}

variable "instance_count" {
  description = "Number of instances"
  type        = map(string)
}