# --------------------- Web Server ---------------------
resource "aws_instance" "web_servers" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.web01.id
  subnet_id     = var.subnet_id

  # This security group should allow all traffic on port 80
  vpc_security_group_ids = [
    var.bastion_sg_id,
    aws_security_group.http.id
  ]

  tags = {
    Name = "WebServer"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo yum install wget unzip httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                wget https://www.tooplate.com/zip-templates/2117_infinite_loop.zip
                unzip -o 2117_infinite_loop.zip
                cp -r 2117_infinite_loop/* /var/www/html/
                sudo systemctl restart httpd
                EOF
}