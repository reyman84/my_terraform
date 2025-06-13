resource "aws_instance" "jenkins_master" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.jenkins_master.id
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [
    var.bastion_sg_id,
    aws_security_group.jenkins_master.id
  ]

  tags = {
    Name = "Jenkins_Master"
  }
}