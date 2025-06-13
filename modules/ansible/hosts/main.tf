# --------------------- Ansible Host on 2 different AMIs ---------------------
resource "aws_instance" "ansible_hosts" {
  for_each = var.ansible_hosts_config

  ami           = each.value.ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ansible_hosts.id
  subnet_id     = each.value.subnet_id

  vpc_security_group_ids = [
    var.bastion_sg_id,
    var.ssh_bastion_sg_id
  ]

  tags = {
    Name = "Ansible_Host_${each.key}"
  }
}