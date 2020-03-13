data "aws_availability_zones" "az" {}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_configuration" "main" {
  name_prefix     = var.launch_configuration_name_prefix
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.instance_type
  security_groups = var.security_groups

  user_data = file(var.user_data_path)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  name                 = "ASG-${aws_launch_configuration.main.name}"
  launch_configuration = aws_launch_configuration.main.name
  min_size             = var.autoscaling_group_min_size
  max_size             = var.autoscaling_group_max_size
  min_elb_capacity     = var.autoscaling_group_min_elb_capacity
  health_check_type    = var.autoscaling_group_health_check_type

  vpc_zone_identifier = var.vpc_zone_identifier

  load_balancers = [aws_elb.main.name]

  wait_for_capacity_timeout = var.autoscaling_group_wait_for_capacity_timeout

  dynamic "tag" {
    for_each = {
      Name   = "ASG Web Server"
      Owner  = "Hleb Straltsou"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "main" {
  name = var.elb_name

  subnets = var.vpc_subnets

  security_groups = var.security_groups

  listener {
    lb_port           = var.listener_elb_port
    lb_protocol       = var.listener_elb_protocol
    instance_port     = var.listener_instance_port
    instance_protocol = var.listener_instance_protocol
  }

  health_check {
    healthy_threshold   = var.elb_health_check_healthy_threshold
    unhealthy_threshold = var.elb_health_check_unhealthy_threshold
    timeout             = var.elb_health_check_timeout
    target              = var.elb_health_check_target
    interval            = var.elb_health_check_interval
  }

  tags = var.tags
}
