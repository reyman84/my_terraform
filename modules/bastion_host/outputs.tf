/*output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
}*/

output "bastion_sg_id" {
  value = aws_security_group.bastion_host.id
}

output "ssh_bastion_sg_id" {
  value = aws_security_group.ssh_from_bastion_host.id
}

output "bastion_key_pair_name" {
  description = "Key pair name for bastion host"
  value       = aws_key_pair.bastion_host.key_name
}
