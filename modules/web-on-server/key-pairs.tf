# Key-Pair
resource "aws_key_pair" "web01" {
  key_name   = "web01"
  public_key = file("key_files/web01.pub")
}