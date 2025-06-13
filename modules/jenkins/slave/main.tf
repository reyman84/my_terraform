/*resource "aws_instance" "jenkins_slave" {
  ami           = data.aws_ami.linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.jenkins_slave.id
  subnet_id     = aws_subnet.public["1b"].id

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.ssh_from_bastion_host.id
  ]

  tags = {
    Name = "Jenkins_Slave"
  }
}

# Create an additional EBS volume for "/tmp"
resource "aws_ebs_volume" "jenkins_slave_volume" {
  availability_zone = aws_instance.jenkins_slave.availability_zone
  size              = 2
  type              = "gp2"

  tags = {
    Name = "/tmp - jenkins slave"
  }
}

# 2. Attach the EBS volume to the Jenkins slave instance
resource "aws_volume_attachment" "jenkins_slave_attachment" {
  device_name  = "/dev/sdf"
  volume_id    = aws_ebs_volume.jenkins_slave_volume.id
  instance_id  = aws_instance.jenkins_slave.id
  force_detach = true
}

# Run commands when the volume is attached using remote-exec provisioner
resource "null_resource" "volume_provisioner_slave" {
  depends_on = [aws_volume_attachment.jenkins_slave_attachment]


  provisioner "file" {
    source      = "installation_scripts/jenkins_slave.sh"
    destination = "/home/ec2-user/jenkins_slave.sh"
  }

  #provisioner "file" {
  #  source      = "key_files"
  #  destination = "/home/ec2-user/key_files"
  #}

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key_files/jenkins_slave")
    host        = aws_instance.jenkins_slave.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdf",
      "sudo mount /dev/xvdf /tmp",
      "sudo -i -u root bash -c 'echo \"/dev/xvdf  /tmp  ext4  defaults,nofail  0  2\" >> /etc/fstab'",
      "mount -a",
      "df -h /tmp",
      "sudo yum install -y dos2unix",
      "dos2unix /home/ec2-user/jenkins_slave.sh",
      "sudo chmod 755 /home/ec2-user/jenkins_slave.sh",
      "sudo sh /home/ec2-user/jenkins_slave.sh",
      "sudo reboot"
    ]
  }
}*/