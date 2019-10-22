provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_security_group" "dr-tf-sg-dmz" {
  name        = "dr-tf-sg-dmz"
  description = "Security Group for Public resources."
  vpc_id      = "${aws_vpc.dr-tf-vpc.id}"

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

  # Gunicorn Access
  ingress {
    from_port   = 8000
    to_port     = 8000
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

resource "aws_alb" "web" {
  name            = "dr-tf-alb"
  subnets         = ["${aws_subnet.dr-tf-sub-dmz-a.id}", "${aws_subnet.dr-tf-sub-dmz-b.id}", "${aws_subnet.dr-tf-sub-dmz-c.id}"]
  # availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]
  security_groups = ["${aws_security_group.dr-tf-sg-dmz.id}"]
  # instances       = ["${aws_instance.dr-info-test-1.id}", "${aws_instance.dr-info-test-2.id}"]
  load_balancer_type = "application"
}
  # listener {
  #   instance_port     = 8000
  #   instance_protocol = "http"
  #   lb_port           = 80
  #   lb_protocol       = "http"
  # }

resource "aws_lb_listener" "web" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.web.arn}"
  }
  
}

resource "aws_lb_target_group" "web" {
  name     = "dr-tf-alb-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.dr-tf-vpc.id}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
resource "aws_lb_target_group_attachment" "dr-info-test-1" {
  target_group_arn = "${aws_lb_target_group.web.arn}"
  target_id        = "${aws_instance.dr-info-test-1.id}"
  port             = 8000
}
resource "aws_lb_target_group_attachment" "dr-info-test-2" {
  target_group_arn = "${aws_lb_target_group.web.arn}"
  target_id        = "${aws_instance.dr-info-test-2.id}"
  port             = 8000
}


resource "aws_instance" "dr-info-test-1" {
  ami                    = "ami-0b69ea66ff7391e80"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.dr-tf-sg-dmz.id}"]
  subnet_id              = "${aws_subnet.dr-tf-sub-dmz-a.id}"
  key_name               = "${aws_key_pair.auth.id}"

  connection {
    user        = "ec2-user"
    host        = "${self.public_ip}"
    type        = "ssh"
    private_key = "${file("~/.ssh/terraform.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum upgrade -y",
      "sudo yum install git -y",
      "git clone https://github.com/dustinreed-info/dr-info-website-flask",
      "sudo yum install python37 -y",
      "pip3 install flask python-dotenv flask-wtf gunicorn --user",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~/dr-info-website-flask",
      "git checkout dev",
      "sudo cp ./drinfo.service /etc/systemd/system/drinfo.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start drinfo",
    ]
  }
}

resource "aws_instance" "dr-info-test-2" {
  ami                    = "ami-0b69ea66ff7391e80"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.dr-tf-sg-dmz.id}"]
  subnet_id              = "${aws_subnet.dr-tf-sub-dmz-b.id}"
  key_name               = "${aws_key_pair.auth.id}"

  connection {
    user        = "ec2-user"
    host        = "${self.public_ip}"
    type        = "ssh"
    private_key = "${file("~/.ssh/terraform.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum upgrade -y",
      "sudo yum install git -y",
      "git clone https://github.com/dustinreed-info/dr-info-website-flask",
      "sudo yum install python37 -y",
      "pip3 install flask python-dotenv flask-wtf gunicorn --user",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~/dr-info-website-flask",
      "git checkout dev",
      "sudo cp ./drinfo.service /etc/systemd/system/drinfo.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start drinfo",
    ]
  }
}

resource "aws_vpc" "dr-tf-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "dr-tf-igw" {
  vpc_id = "${aws_vpc.dr-tf-vpc.id}"
}

resource "aws_route" "dr-tf-pub-rt" {
  route_table_id         = "${aws_vpc.dr-tf-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.dr-tf-igw.id}"
}

resource "aws_subnet" "dr-tf-sub-dmz-a" {
  cidr_block              = "10.0.100.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
  availability_zone_id    = "use1-az4"
}

resource "aws_subnet" "dr-tf-sub-dmz-b" {
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
  availability_zone_id    = "use1-az6"
}

resource "aws_subnet" "dr-tf-sub-dmz-c" {
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
  availability_zone_id    = "use1-az1"
}

# resource "aws_subnet" "dr-tf-sub-dmz-d" {
#   cidr_block              = "10.0.103.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az2"
# }


# resource "aws_subnet" "dr-tf-sub-dmz-e" {
#   cidr_block              = "10.0.104.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az3"
# }


# resource "aws_subnet" "dr-tf-sub-dmz-f" {
#   cidr_block              = "10.0.105.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az5"
# }


# resource "aws_security_group" "dr-tf-sg-private" {
#   name        = "dr-tf-sg-private"
#   description = "Security Group for Private resources."
#   vpc_id      = "${aws_vpc.dr-tf-vpc.id}"
# }


# resource "aws_subnet" "dr-tf-sub-private-a" {
#   cidr_block              = "10.0.200.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az4"
# }


# resource "aws_subnet" "dr-tf-sub-private-b" {
#   cidr_block              = "10.0.201.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az6"
# }


# resource "aws_subnet" "dr-tf-sub-private-c" {
#   cidr_block              = "10.0.202.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az1"
# }


# resource "aws_subnet" "dr-tf-sub-private-d" {
#   cidr_block              = "10.0.203.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az2"
# }


# resource "aws_subnet" "dr-tf-sub-private-e" {
#   cidr_block              = "10.0.204.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az3"
# }


# resource "aws_subnet" "dr-tf-sub-private-f" {
#   cidr_block              = "10.0.205.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az5"
# }

