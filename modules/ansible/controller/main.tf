resource "aws_instance" "ansible_cm" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ansible.id
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key_files/ansible") # This is your PRIVATE key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "key_files/ansible"
    destination = "/home/ubuntu/clientkey"
  }

  /*provisioner "file" {
    source      = "installation_scripts/inventory"
    destination = "/home/ubuntu/inventory"
  }*/

  provisioner "file" {
    source      = "installation_scripts/ansible.sh"
    destination = "/home/ubuntu/ansible.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y dos2unix",
      "dos2unix /home/ubuntu/ansible.sh",
      "sudo chmod +x /home/ubuntu/ansible.sh",
      "sudo sh /home/ubuntu/ansible.sh",
      "sudo ansible-galaxy collection install amazon.aws --force"
    ]
  }

  tags = {
    Name = "Ansible Control Machine"
  }
}