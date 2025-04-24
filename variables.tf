variable "region" {
  default = "us-east-1"
}

variable "trusted_ip" {
  default = "49.207.50.91/32"
}


variable "public_subnet" {
  description = "Map of public subnets"
  type        = map(string)
  default = {
    "1a" = "10.0.10.0/24"
    "1b" = "10.0.20.0/24"
    "1c" = "10.0.30.0/24"
    "1d" = "10.0.40.0/24"
    "1e" = "10.0.50.0/24"
    "1f" = "10.0.60.0/24"
  }
}

variable "private_subnet" {
  description = "Map of private subnets"
  type        = map(string)
  default = {
    1 = "10.0.70.0/24"
    2 = "10.0.80.0/24"
    3 = "10.0.90.0/24"
  }
}

variable "zone" {
  description = "Map of zones"
  type        = map(string)
  default = {
    "1a" = "us-east-1a"
    "1b" = "us-east-1b"
    "1c" = "us-east-1c"
    "1d" = "us-east-1d"
    "1e" = "us-east-1e"
    "1f" = "us-east-1f"
  }
}

variable "cidr_block" {
  default = "0.0.0.0/0"
}

variable "ami" {
  description = "Map of AMI IDs for different types of instances"
  type        = map(string)
  default = {
    amazon_linux_2 = "ami-00a929b66ed6e0de6"
    ubuntu         = "ami-084568db4383264d4"
    jenkins_master = "ami-0e3f9fdf9e0cf2837"
    #ansible_host   = "ami-0b74b23e2438b6f44"     - CentOS 09 "Chargeable"
  }
}

variable "instant_count" {
  description = "Number of instances"
  type        = map(string)
  default = {
    stable   = "1"
    unstable = "2"
  }
}


variable "stable_instance_count" {
  description = "Number of EC2 instances to launch"
  type        = number
  default     = 1
}

variable "unstable_instance_count" {
  description = "Number of EC2 instances to launch"
  type        = number
  default     = 1
}

variable "ports" {
  description = "Map of named ports"
  type        = map(number)
  default = {
    ssh     = 22
    http    = 80
    jenkins = 8080
  }
}