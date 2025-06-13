output "docker_host_public_ip" {
  value = aws_instance.docker.public_ip
}
