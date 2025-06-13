# Region & Access Config
region     = "us-east-1"
trusted_ip = "49.207.50.91/32"

# VPC & Subnet CIDRs
vpc_cidr = "10.0.0.0/16"

zone = {
  "1a" = "us-east-1a"
  "1b" = "us-east-1b"
  "1c" = "us-east-1c"
  #"1d" = "us-east-1d"
  #"1e" = "us-east-1e"
  #"1f" = "us-east-1f"
}

public_subnet = {
  "1a" = "10.0.10.0/24"
  "1b" = "10.0.20.0/24"
  "1c" = "10.0.30.0/24"
  #"1d" = "10.0.40.0/24"
  #"1e" = "10.0.50.0/24"
  #"1f" = "10.0.60.0/24"
}

private_subnet = {
  "1a" = "10.0.70.0/24"
  "1b" = "10.0.80.0/24"
  "1c" = "10.0.90.0/24"
  #"1d" = "10.0.100.0/24"
  #"1e" = "10.0.110.0/24"
  #"1f" = "10.0.120.0/24"
}

# AMI Configuration
ami = {
  #"amazon_linux_2" = "ami-00a929b66ed6e0de6"
  #"ubuntu"         = "ami-084568db4383264d4"
  jenkins_master = "ami-0c108e5c67c89529f"
  nexus          = "ami-00f118865d6050541"
  sonarqube      = "ami-09772d5953c979b8d"
}

# Instance Scaling Setup
instance_count = {
  stable   = 1
  unstable = 2
}