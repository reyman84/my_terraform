# Key-Pair
resource "aws_key_pair" "ansible_hosts" {
  key_name   = "ansible_hosts"
  public_key = file("key_files/ansible_hosts.pub")
}