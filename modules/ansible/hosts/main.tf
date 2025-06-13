# --------------------- Ansible Host on 2 different AMIs ---------------------

/*locals {
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
}*/

resource "aws_instance" "ansible_hosts" {
  #for_each = local.instances
  #ami      = each.value
  ami = var.ami

  instance_type = "t2.micro"
  key_name      = aws_key_pair.ansible_hosts.id

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    var.bastion_sg_id,
    var.ssh_bastion_sg_id
  ]

  tags = {
    Name = "Ansible_hosts"
  }
}