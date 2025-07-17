variable "region" {
  description = "Provides the AWS region to implement changes"
}

variable "trusted_ip" {
  description = "IP address of my Laptop's IP"
}

variable "VPC_NAME" {
  default = "Terraform-VPC"
}

variable "Zone1" {
  default = "us-east-1a"
}

variable "Zone2" {
  default = "us-east-1b"
}

variable "Zone3" {
  default = "us-east-1c"
}

variable "VpcCIDR" {
  default = "172.21.0.0/16"
}

variable "PubSub1CIDR" {
  default = "172.21.1.0/24"
}

variable "PubSub2CIDR" {
  default = "172.21.2.0/24"
}

variable "PubSub3CIDR" {
  default = "172.21.3.0/24"
}

variable "PrivSub1CIDR" {
  default = "172.21.4.0/24"
}

variable "PrivSub2CIDR" {
  default = "172.21.5.0/24"
}

variable "PrivSub3CIDR" {
  default = "172.21.6.0/24"
}

variable "PROJECT" {
  default = "vprofile"
}

/*variable "ami" {
  description = "AMI value for different types of instances"
  type        = map(string)
}

variable "instance_count" {
  description = "Number of instances"
  type        = map(string)
}*/