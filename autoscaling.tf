/*
# Data source: query the list of availability zones
# data "aws_availability_zones" "all" {}

# --------------------- Launch Template --------------------- #

# Launch Template (EC2 instance configuration)
resource "aws_launch_template" "web_launch_template" {
  name          = "Web-Launch-Template"
  image_id      = var.ami["amazon_linux_2"]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.web01.id

  network_interfaces {
    security_groups             = [aws_security_group.web01.id]
    associate_public_ip_address = false
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum install wget unzip httpd -y
              sudo systemctl start httpd
              sudo systemctl enable httpd
              wget https://www.tooplate.com/zip-templates/2117_infinite_loop.zip
              unzip -o 2117_infinite_loop.zip
              sudo cp -r 2117_infinite_loop/* /var/www/html/
              sudo systemctl restart httpd
              EOF 
  )

  lifecycle { create_before_destroy = true }

}

# Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "web_asg" {
  for_each            = aws_subnet.private_subnets
  vpc_zone_identifier = [each.value.id]
  desired_capacity    = 2
  min_size            = 2
  max_size            = 5

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.Terraform_web_tg.arn]

  tag {
    key                 = "Name"
    value               = "Web-Instance"
    propagate_at_launch = true
  }
}*/