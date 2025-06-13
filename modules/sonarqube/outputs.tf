output "sonarqube_ip" {
  value = aws_instance.sonarqube.public_ip
}

output "sonarqube_sg_id" {
  description = "sonarqube SG ID"
  value       = aws_security_group.sonarqube_sg.id
}
