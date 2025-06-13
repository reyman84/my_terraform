output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_master_sg_id" {
  description = "Security Group ID of Jenkins Master"
  value       = aws_security_group.jenkins_master.id
}
