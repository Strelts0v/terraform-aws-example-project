provider "aws" {
  version = "~> 2.52"
  region = "eu-central-1"
  access_key = "AKIA6PRLPDC6NQM3LV43"
  secret_key = "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"
}

data "aws_availability_zones" "az" {}

# data "aws_ami" "latest_ubuntu" {
#   owners      = ["099720109477"]
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }
# }

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "web_server" {
  name = "Web Server Security Group"

  dynamic "ingress" {
    for_each = ["8080", "80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Web Server Security Group"
    Owner = "Hleb Straltsou"
  }
}

resource "aws_launch_configuration" "web_server" {
  name_prefix     = "Web-Server-LC-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_server.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_server" {
  name                 = "ASG-${aws_launch_configuration.web_server.name}"
  launch_configuration = aws_launch_configuration.web_server.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"

  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  load_balancers       = [aws_elb.web_server.name]

  wait_for_capacity_timeout = "30m"

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

resource "aws_elb" "web_server" {
  name               = "Web-Server-ELB"

  availability_zones = [data.aws_availability_zones.az.names[0], data.aws_availability_zones.az.names[1]]
  security_groups    = [aws_security_group.web_server.id]

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
    Name = "Web-Server-ELB"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.az.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.az.names[1]
}

output "web_loadbalancer_url" {
  value = aws_elb.web_server.dns_name
}
