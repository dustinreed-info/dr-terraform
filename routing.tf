resource "aws_route_table" "dr-tf-private-rtable" {
  vpc_id = "${aws_vpc.dr-tf-vpc.id}"
  route {
    nat_gateway_id = aws_nat_gateway.dr-tf-nat.id
    cidr_block     = "0.0.0.0/0"
  }
  tags = {
    Name  = "dr-tf-private-rtable"
    Group = "dr-tf-info"
  }
}


resource "aws_route_table" "dr-tf-pub-rtable" {
  vpc_id = "${aws_vpc.dr-tf-vpc.id}"

  route {
    gateway_id = aws_internet_gateway.dr-tf-igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name  = "dr-tf-pub-rtable"
    Group = "dr-tf-info"
  }
}

resource "aws_route_table_association" "dmz-a" {
  subnet_id      = "${aws_subnet.dr-tf-sub-dmz-a.id}"
  route_table_id = "${aws_route_table.dr-tf-pub-rtable.id}"
}
resource "aws_route_table_association" "dmz-b" {
  subnet_id      = "${aws_subnet.dr-tf-sub-dmz-b.id}"
  route_table_id = "${aws_route_table.dr-tf-pub-rtable.id}"
}
resource "aws_route_table_association" "dmz-c" {
  subnet_id      = "${aws_subnet.dr-tf-sub-dmz-c.id}"
  route_table_id = "${aws_route_table.dr-tf-pub-rtable.id}"
}
resource "aws_route_table_association" "private-a" {
  subnet_id      = "${aws_subnet.dr-tf-sub-private-a.id}"
  route_table_id = "${aws_route_table.dr-tf-private-rtable.id}"
}
resource "aws_route_table_association" "private-b" {
  subnet_id      = "${aws_subnet.dr-tf-sub-private-b.id}"
  route_table_id = "${aws_route_table.dr-tf-private-rtable.id}"
}
resource "aws_route_table_association" "private-c" {
  subnet_id      = "${aws_subnet.dr-tf-sub-private-c.id}"
  route_table_id = "${aws_route_table.dr-tf-private-rtable.id}"
}



# resource "aws_route_table_association" "dmz-d" {
#   subnet_id = "${aws_subnet.dr-tf-sub-dmz-d.id}"
#   route_table_id = "${aws_route_table.dr-tf-pub-rtable.id}"
# }
# resource "aws_route_table_association" "dmz-e" {
#   subnet_id = "${aws_subnet.dr-tf-sub-dmz-e.id}"
#   route_table_id = "${aws_route_table.dr-tf-pub-rtable.id}"
# }
# resource "aws_route_table_association" "dmz-f" {
#   subnet_id = "${aws_subnet.dr-tf-sub-dmz-f.id}"
#   route_table_id = "${aws_route_table.dr-tf-pub-rtable.id}"
# }
# resource "aws_route_table_association" "private-d" {
#   subnet_id = "${aws_subnet.dr-tf-sub-private-d.id}"
#   route_table_id = "${aws_route_table.dr-tf-private-rtable.id}"
# }
# resource "aws_route_table_association" "private-e" {
#   subnet_id = "${aws_subnet.dr-tf-sub-private-e.id}"
#   route_table_id = "${aws_route_table.dr-tf-private-rtable.id}"
# }
# resource "aws_route_table_association" "private-f" {
#   subnet_id = "${aws_subnet.dr-tf-sub-private-f.id}"
#   route_table_id = "${aws_route_table.dr-tf-private-rtable.id}"
# }