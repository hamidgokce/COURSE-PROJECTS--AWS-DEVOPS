resource "aws_autoscaling_group" "web-asg" {
  name                      = "web-asg"
  depends_on                = [aws_internet_gateway.aws_capstone_vpc_igw, aws_db_instance.my_db_instance, aws_s3_bucket.aws_capstone_bucket, aws_lb_target_group.aws_capstone_target_group] # If autoscaling doesn't wait RDS instance, migration command of userdata has problem. 
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 90
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.aws_capstone_vpc_private_subnet_A.id, aws_subnet.aws_capstone_vpc_private_subnet_B.id]
  launch_template {
    id      = aws_launch_template.aws_capstone_launch_template.id
    version = "$Latest"
  }
  target_group_arns     = [aws_lb_target_group.aws_capstone_target_group.arn]
  tag {
    key                 = "name"
    value               = local.name
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }
}


resource "aws_autoscaling_policy" "web_cluster_target_tracking_policy" {
  name                      = "staging-web-cluster-target-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.web-asg.name
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = "70"

  }
}

