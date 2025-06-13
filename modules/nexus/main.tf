# --------------------- Nexus Setup ---------------------
# ---------------- on top of Amazon AMI -----------------

resource "aws_instance" "nexus" {
  ami           = var.ami
  instance_type = "t2.medium"
  key_name      = var.key_pair_name
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [
    var.bastion_sg_id,
    aws_security_group.nexus_sg.id
  ]

  tags = {
    Name = "Nexus"
  }

}