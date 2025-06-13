# --------------------- Docker Engine & Docker Compose ---------------------
# --------------------------- on Amazon-Linux-2 ----------------------------

resource "aws_instance" "docker" {
  instance_type = "t2.micro"               # t2-medium is "Chargeable"
  ami           = var.ami
  key_name               = var.key_pair_name 
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [
    var.bastion_sg_id,
    aws_security_group.All_Traffic_enabled.id
  ]

  tags = {
    Name = "Docker"
  }

  provisioner "file" {
    source      = "installation_scripts/docker.sh"
    destination = "/home/ec2-user/docker.sh"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key_files/bastion-host")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "sudo yum install -y dos2unix",
      "dos2unix /home/ec2-user/docker.sh",
      "sudo chmod +x /home/ec2-user/docker.sh",
      "sudo sh /home/ec2-user/docker.sh"
    ]
  }
}