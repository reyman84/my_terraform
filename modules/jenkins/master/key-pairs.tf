# Key-Pair
resource "aws_key_pair" "jenkins_master" {
  key_name   = "jenkins_master"
  public_key = file("key_files/jenkins_master.pub")
}