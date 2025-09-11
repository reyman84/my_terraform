/*output "bastion_host" {
  description = "Public and Private IPs of Controller"
  value = {
    public  = aws_instance.bastion_host.public_ip
    private = aws_instance.bastion_host.private_ip
  }
}*/

output "controller_ips" {
  description = "Public and Private IPs of Controller"
  value = {
    public  = aws_instance.ansible_controller_ubuntu.public_ip
    private = aws_instance.ansible_controller_ubuntu.private_ip
  }
}

output "ansible_host_ubuntu_ips" {
  description = "Public and Private IPs of ansible host ubuntu"
  value = {
    public  = aws_instance.ansible_host_ubuntu.public_ip
    private = aws_instance.ansible_host_ubuntu.private_ip
  }
}

output "ansible_host_amazonlinux_ips" {
  description = "Public and Private IPs of ansible host amazonlinux"
  value = {
    public  = aws_instance.ansible_host_amazonlinux.public_ip
    private = aws_instance.ansible_host_amazonlinux.private_ip
  }
}

/*output "Jenkins_Master" {
  description = "Public and Private IPs of Jenkins_Master"
  value = {
    public  = aws_instance.jenkins_master.public_ip
    private = aws_instance.jenkins_master.private_ip
  }
}

output "Jenkins_Slave" {
  description = "Public and Private IPs of Jenkins_Slave"
  value = {
    public  = aws_instance.jenkins_slave.public_ip
    private = aws_instance.jenkins_slave.private_ip
  }
}

output "Nexus" {
  description = "Public and Private IPs of Nexus"
  value = {
    public  = aws_instance.nexus.public_ip
    private = aws_instance.nexus.private_ip
  }
}

output "SonarQube" {
  description = "Public and Private IPs of SonarQube"
  value = {
    public  = aws_instance.sonarqube.public_ip
    private = aws_instance.sonarqube.private_ip
  }
}

output "Docker" {
  description = "Public and Private IPs of Docker instance"
  value = {
    public  = aws_instance.docker.public_ip
    private = aws_instance.docker.private_ip
  }
}*/