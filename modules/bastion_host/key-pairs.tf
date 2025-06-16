# Key-Pairs
resource "aws_key_pair" "bastion_host" {
  key_name   = "bastion-host"
  public_key = file("key_files/bastion-host.pub")
}