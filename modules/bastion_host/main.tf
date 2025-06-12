# --------------------- Bastion Host ---------------------

resource "aws_instance" "bastion_host" {
  instance_type          = "t2.micro"
  ami                    = var.ami
  key_name               = aws_key_pair.bastion_host.id
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "Bastion-Host"
  }

  provisioner "file" {
    source      = "key_files/web01"
    destination = "/home/ec2-user/web01"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key_files/bastion-host")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/web01"
    ]
  }
}
