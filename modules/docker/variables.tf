variable "vpc_id" {
  description = "VPC ID for the Bastion Host security group"
  type        = string
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