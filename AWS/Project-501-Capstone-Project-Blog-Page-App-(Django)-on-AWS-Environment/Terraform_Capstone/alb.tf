
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aws_capstone_ALB_Sec_Group.id]
  subnets            = [aws_subnet.aws_capstone_vpc_public_subnet_A.id, aws_subnet.aws_capstone_vpc_public_subnet_B.id]

  ip_address_type    = "ipv4"
  enable_deletion_protection = false
  tags = local.tags
}

resource "aws_lb_target_group" "aws_capstone_target_group" {
  depends_on  = [aws_instance.initial_ec2]
  name     = "awscapstonetargetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws_capstone_vpc.id

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 5
    timeout = 20
    interval = 50
  }
}


# To install web-app, we need to create initial instance which will create database tables and s3 static files. than autoscaling group creates new other instances in which don't have migrate commands. We'll add this intial instance to the target group. 

resource "aws_lb_target_group_attachment" "aws_target_group_attachment" {
  target_group_arn = aws_lb_target_group.aws_capstone_target_group.arn
  target_id        = aws_instance.initial_ec2.id
  port             = 80
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.certificate_arn_alb

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_capstone_target_group.arn
  }
}