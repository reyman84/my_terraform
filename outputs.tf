output "bastion_host_public_ips" {
  description = "Public IPs of all Bastion Hosts"
  value       = [for instance in aws_instance.bastion_host : instance.public_ip]
}

output "bastion_host_private_ips" {
  description = "Private IPs of all Bastion Hosts"
  value       = [for instance in aws_instance.bastion_host : instance.private_ip]
}

output "Ansible_CM_Public_ip" {
  description = "Generates the Public IP of docker"
  value       = aws_instance.ansible_cm.public_ip
}

output "Ansible_CM_Private_ip" {
  description = "Generates the Private IP of docker"
  value       = aws_instance.ansible_cm.private_ip
}

output "Ansible_Ubuntu_Public_ip" {
  description = "Generates the Public IP of docker"
  value       = aws_instance.ansible_ubuntu.public_ip
}

output "Ansible_Ubuntu_Private_ip" {
  description = "Generates the Private IP of docker"
  value       = aws_instance.ansible_ubuntu.private_ip
}

/*output "Ansible_Hosts_Private_ips" {
  value = {
    for name, inst in aws_instance.ansible_hosts :
    name => inst.private_ip
  }
}

output "Jenkins_Master" {
  description = "Public IPs of Jenkins Master"
  value       = aws_instance.jenkins_master.public_ip
}

output "Nexus" {
  description = "Public IPs of Jenkins Master"
  value       = aws_instance.nexus.public_ip
}

output "SonarQube" {
  description = "Public IPs of Jenkins Master"
  value       = aws_instance.sonarqube.public_ip
}

output "Jenkins_Slave" {
  description = "Public IPs of Jenkins Slave"
  value       = aws_instance.jenkins_slave.public_ip
}

output "Web_Server---Public_IPs" {
  description = "Public IPs of Web Servers"
  value       = [for instance in aws_instance.web_servers : instance.public_ip]
}

output "Web_Server---Private_IPs" {
  description = "Private IPs of Web Servers"
  value       = [for instance in aws_instance.web_servers : instance.private_ip]
}

output "DNS_Name_of_Load_Balancer" {
  description = "Generates the DNS Name of the Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

output "Docker_Public_ip" {
  description = "Generates the Public IP of docker"
  value       = aws_instance.docker.public_ip
}



output "bastion_sg_id" {
  value = aws_security_group.bastion_host.id
}

output "web_sg_id" {
  value = aws_security_group.web01.id
}

output "alb_sg_id" {
  value = aws_security_group.http.id
}*/