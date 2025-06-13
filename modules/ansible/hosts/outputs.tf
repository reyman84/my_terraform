output "ansible_hosts_ips" {
  value = {
    for host, instance in aws_instance.ansible_hosts :
    host => instance.public_ip
  }
}
