# Key-Pair
resource "aws_key_pair" "ansible" {
  key_name   = "ansible"
  public_key = file("key_files/ansible.pub")
}