output "nexus_ip" {
  value = aws_instance.nexus.public_ip
}

output "nexus_sg_id" {
  description = "Nexus SG ID"
  value       = aws_security_group.nexus_sg.id
}
