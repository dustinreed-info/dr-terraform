resource "aws_subnet" "dr-tf-sub-dmz-a" {
  cidr_block              = "10.0.100.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.dr-tf-vpc.id
  availability_zone_id    = "use1-az4"
  tags = {
    Name        = "dr-tf-sub-dmz-a"
    Group       = "dr-info-tf"
    subnet_type = "dmz"
  }
}

resource "aws_subnet" "dr-tf-sub-dmz-b" {
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.dr-tf-vpc.id
  availability_zone_id    = "use1-az6"
  tags = {
    Name        = "dr-tf-sub-dmz-b"
    Group       = "dr-info-tf"
    subnet_type = "dmz"
  }
}

resource "aws_subnet" "dr-tf-sub-dmz-c" {
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.dr-tf-vpc.id
  availability_zone_id    = "use1-az1"
  tags = {
    Name        = "dr-tf-sub-dmz-c"
    Group       = "dr-info-tf"
    subnet_type = "dmz"
  }
}

resource "aws_subnet" "dr-tf-sub-private-a" {
  cidr_block              = "10.0.200.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
  availability_zone_id    = "use1-az4"
  tags = {
    Name        = "dr-tf-sub-private-a"
    Group       = "dr-info-tf"
    subnet_type = "private"
  }
}
resource "aws_subnet" "dr-tf-sub-private-b" {
  cidr_block              = "10.0.201.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
  availability_zone_id    = "use1-az6"
  tags = {
    Name        = "dr-tf-sub-private-b"
    Group       = "dr-info-tf"
    subnet_type = "private"
  }
}
resource "aws_subnet" "dr-tf-sub-private-c" {
  cidr_block              = "10.0.202.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
  availability_zone_id    = "use1-az1"
  tags = {
    Name        = "dr-tf-sub-private-c"
    Group       = "dr-info-tf"
    subnet_type = "private"
  }
}
# resource "aws_subnet" "dr-tf-sub-dmz-d" {
#   cidr_block              = "10.0.103.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az2"
#   tags = {
#     Group = "dr-info-tf"
#     subnet_type = "dmz"
#   }
# }
# resource "aws_subnet" "dr-tf-sub-dmz-e" {
#   cidr_block              = "10.0.104.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az3"
#   tags = {
#     Group = "dr-info-tf"
#     subnet_type = "dmz"
#   }
# }
# resource "aws_subnet" "dr-tf-sub-dmz-f" {
#   cidr_block              = "10.0.105.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az5"
#   tags = {
#     Group = "dr-info-tf"
#     subnet_type = "dmz"
#   }
# }

# resource "aws_subnet" "dr-tf-sub-private-d" {
#   cidr_block              = "10.0.203.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az2"
#   tags = {
#     Group = "dr-info-tf"
#     subnet_type = "private"
#   }
# }
# resource "aws_subnet" "dr-tf-sub-private-e" {
#   cidr_block              = "10.0.204.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az3"
#   tags = {
#     Group = "dr-info-tf"
#     subnet_type = "private"
#   }
# }
# resource "aws_subnet" "dr-tf-sub-private-f" {
#   cidr_block              = "10.0.205.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = "${aws_vpc.dr-tf-vpc.id}"
#   availability_zone_id       = "use1-az5"
#   tags = {
#     Group = "dr-info-tf"
#     subnet_type = "private"
#   }
# }