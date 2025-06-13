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

variable "nexus_sg_id" {
  description = "Security group ID of Nexus to allow ingress"
  type        = string
  default     = null
}
