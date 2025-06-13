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

# ✅ New map-based input
variable "ansible_hosts_config" {
  description = "AMI and subnet config per host"
  type = map(object({
    ami       = string
    subnet_id = string
  }))
}

variable "bastion_sg_id" {
  type = string
}

variable "ssh_bastion_sg_id" {
  type = string
}