locals {
  ports = {
    ssh     = 22
    http    = 80
    jenkins = 8080
    nexus   = 8081
  }
}

locals {
  instances = {
    "Host - Amazon_Linux" = data.aws_ami.linux.id
    "Host - Ubuntu"       = data.aws_ami.ubuntu.id
  }
}

locals {
  subnet_id = {
    "Host - Amazon_Linux" = aws_subnet.public["1a"].id
    "Host - Ubuntu"       = aws_subnet.public["1b"].id
  }
}