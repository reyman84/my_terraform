# Key-Pair
resource "aws_key_pair" "jenkins_slave" {
  key_name   = "jenkins_slave"
  public_key = file("key_files/jenkins_slave.pub")
}