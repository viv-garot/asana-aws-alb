terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_subnet_ids" "subs" {
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vivien-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vivien-igw"
  }
}

resource "aws_default_route_table" "route" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_subnet" "sub1" {
  vpc_id               = aws_vpc.main.id
  cidr_block           = "10.0.3.0/24"
  availability_zone_id = "euc1-az2"

  tags = {
    Name = "subnet-main-vivien"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id               = aws_vpc.main.id
  cidr_block           = "10.0.2.0/24"
  availability_zone_id = "euc1-az1"

  tags = {
    Name = "subnet-main-vivien"
  }
}


resource "aws_launch_configuration" "webserver" {
  instance_type   = "t2.micro"
  image_id        = data.aws_ami.ubuntu.id
  security_groups = [aws_security_group.instance.id]
  key_name        = "vivien"

  user_data = <<-EOF
            #!/bin/bash
            echo "Sapee" > index.html
            nohup busybox httpd -f -p ${var.server_port} &
            EOF

  # Required when using a launch configuration with an ASG
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ASG-WebServer" {
  launch_configuration = aws_launch_configuration.webserver.name
  vpc_zone_identifier  = data.aws_subnet_ids.subs.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 5

  tag {
    key                 = "Name"
    value               = "vivien-ASG"
    propagate_at_launch = true
  }

}

resource "aws_lb" "lb-example" {
  name               = "vivien-ASG"
  load_balancer_type = "application"
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
  security_groups    = [aws_security_group.vivien-alb.id]

  depends_on = [aws_internet_gateway.gw]

}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.lb-example.arn
  port              = 80
  protocol          = "HTTP"

  # By default return a simple 404 error page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "vivien-alb" {
  name   = "vivien-SG-WS-alb"
  vpc_id = aws_vpc.main.id

  # Allow inbound HTTP requests
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  # Allow outbound HTTP requests
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

}

resource "aws_security_group" "instance" {
  name   = var.instance_security_group_name
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "asg-example-WS"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = "15"
    timeout             = "3"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_alb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }

}
