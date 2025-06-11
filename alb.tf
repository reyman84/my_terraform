/*resource "aws_lb_target_group" "Terraform_web_tg" {
  name        = "Terraform-Web-TG"
  vpc_id      = aws_vpc.vpc.id
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb" "web_alb" {
  name                       = "terraform-web-alb"
  internal                   = false # public alb
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.http.id] # only port 80 from anywhere
  subnets                    = [aws_subnet.public["1a"].id, aws_subnet.public["1b"].id]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Terraform_web_tg.arn
  }
}*/