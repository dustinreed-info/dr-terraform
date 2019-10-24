provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

data "template_file" "dr-tf-ec2-cfg" {
  template = "${file("./config.tpl")}"
}

resource "aws_vpc" "dr-tf-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name  = "dr-tf-vpc"
    Group = "dr-tf-info"
  }
}

resource "aws_internet_gateway" "dr-tf-igw" {
  vpc_id = aws_vpc.dr-tf-vpc.id
  tags = {
    Name  = "dr-tf-igw"
    Group = "dr-tf-info"
  }
}

resource "aws_nat_gateway" "dr-tf-nat" {
  allocation_id = "${aws_eip.dr-tf-nat-ip.id}"
  subnet_id     = "${aws_subnet.dr-tf-sub-dmz-a.id}"
  depends_on    = [aws_internet_gateway.dr-tf-igw]
  tags = {
    Name  = "dr-tf-nat"
    Group = "dr-info-tf"
  }
}

resource "aws_eip" "dr-tf-nat-ip" {
  vpc = true
  tags = {
    Name  = "dr-tf-nat-ip"
    Group = "dr-tf-info"
  }
}

resource "aws_security_group" "dr-tf-sg-dmz" {
  name        = "dr-tf-sg-dmz"
  description = "Security Group for Public resources."
  vpc_id      = "${aws_vpc.dr-tf-vpc.id}"
  tags = {
    Name  = "dr-tf-sg-dmz"
    Group = "dr-info-tf"
  }

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dr-tf-sg-private" {
  name        = "dr-tf-sg-private"
  description = "Security Group for Private resources."
  vpc_id      = "${aws_vpc.dr-tf-vpc.id}"
  tags = {
    Name  = "dr-tf-sg-private"
    Group = "dr-info-tf"
  }

  # SSH Access
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.dr-tf-sg-dmz.id}"]
  }

  # Gunicorn Access
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.dr-tf-sg-dmz.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "dr-tf-alb" {
  name               = "dr-tf-alb"
  subnets            = [aws_subnet.dr-tf-sub-dmz-a.id, aws_subnet.dr-tf-sub-dmz-b.id, aws_subnet.dr-tf-sub-dmz-c.id]
  security_groups    = [aws_security_group.dr-tf-sg-dmz.id]
  load_balancer_type = "application"
  tags = {
    Name  = "dr-tf-alb"
    Group = "dr-tf-info"
  }
}

resource "aws_lb_listener" "dr-tf-alb-listener" {
  load_balancer_arn = aws_alb.dr-tf-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dr-tf-alb-tg.arn
  }
}

resource "aws_lb_target_group" "dr-tf-alb-tg" {
  name     = "dr-tf-alb-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.dr-tf-vpc.id
  tags = {
    Name  = "dr-tf-alb-tg"
    Group = "dr-tf-info"
  }
}

resource "aws_autoscaling_attachment" "dr-tf-asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.dr-tf-asg.id
  alb_target_group_arn   = aws_lb_target_group.dr-tf-alb-tg.arn
}

resource "aws_launch_template" "dr-tf-asg-ltemplate" {
  name_prefix            = "dr-info-tf"
  image_id               = "ami-0b69ea66ff7391e80"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.dr-tf-sg-private.id}"]
  key_name               = "${aws_key_pair.auth.id}"
  user_data              = "${base64encode("${data.template_file.dr-tf-ec2-cfg.rendered}")}"
  tags = {
    Name  = "dr-tf-asg-ltemplate"
    Group = "dr-tf-info"
  }
}

resource "aws_autoscaling_group" "dr-tf-asg" {
  name                      = "dr-tf-asg"
  min_size                  = 2
  max_size                  = 5
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.dr-tf-sub-dmz-a.id, aws_subnet.dr-tf-sub-dmz-b.id, aws_subnet.dr-tf-sub-dmz-c.id]
  tags = [{
    key                 = "Name"
    value               = "dr-tf-asg"
    propagate_at_launch = true
    },
    {
      key                 = "Group"
      value               = "dr-tf-info"
      propagate_at_launch = true
    }
  ]
  launch_template {
    id      = aws_launch_template.dr-tf-asg-ltemplate.id
    version = "$Latest"
  }
}