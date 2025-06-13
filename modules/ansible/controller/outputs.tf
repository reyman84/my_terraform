output "ansible_cm_ip" {
  value = aws_instance.ansible_cm.public_ip
}