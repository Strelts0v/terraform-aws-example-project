data "aws_availability_zones" "available" {}

data "aws_ami" "latest_ubuntu_18_04" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_launch_configuration" "pet_project" {
  name_prefix     = "Pet-Project-LC-"
  image_id        = data.aws_ami.latest_ubuntu_18_04.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.pet_project.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "pet_project" {
  name                 = "ASG-${aws_launch_configuration.pet_project.name}"
  launch_configuration = aws_launch_configuration.pet_project.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"

  // Any AZ has at least 2 AZ
  vpc_zone_identifier = [
    aws_subnet.pet_project_subnet_a.default_az1.id,
    aws_subnet.pet_project_subnet_b.default_az2.id
  ]

  load_balancers = [aws_elb.pet_project.name]

  dynamic "tag" {
    for_each = {
      Name   = "EC2 instance in ASG"
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

resource "aws_elb" "pet_project" {
  name = "Pet-Project-ELB"
  availability_zones = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]
  ]
  security_groups = [aws_security_group.pet_project.id]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  tags = {
    Name = "Pet-Project-ELB"
  }
}
