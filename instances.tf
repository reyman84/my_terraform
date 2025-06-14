# --------------------- Manual-Project ---------------------
# --------------------- MYSQL/ Mariadb ---------------------

/*resource "aws_instance" "manual_project_sql" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.linux.id
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public["1a"].id

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.http.id
  ]

  tags = {
    Name = "Manual_Project_SQL"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key_files/bastion-host")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      # Installing MariaDB and GIT
      "sudo dnf install -y git mariadb105-server",
      "sudo systemctl start mariadb",
      "sudo systemctl enable mariadb",
      "mysql --version",
      #"sudo systemctl status mariadb",
      "cd /tmp",
      "git clone -b local https://github.com/hkhcoder/vprofile-project.git"
    ]
  }
}*/