output "jenkins_slave_ip" {
  value = aws_instance.jenkins_slave.public_ip
}