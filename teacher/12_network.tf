
resource "aws_vpc" "workshop_vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "workshop_subnet_primary" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  vpc_id = "${aws_vpc.workshop_vpc.id}"
}

resource "aws_subnet" "workshop_subnet_secondary" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  vpc_id = "${aws_vpc.workshop_vpc.id}"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.workshop_vpc.id}"
}

resource "aws_security_group" "workshop_security" {
  name = "workshop_security"
  description = "Workshop port openings"
  vpc_id = "${aws_vpc.workshop_vpc.id}"

  #
  # common ports
  #

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #
  # elasticsearch
  #

  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 9300
    to_port = 9300
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 5601
    to_port = 5601
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [ "${aws_vpc.workshop_vpc.cidr_block}" ]
  }


  #
  # outgoing traffic
  #

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_internet_gateway" "workshop_igw" {
  vpc_id = "${aws_vpc.workshop_vpc.id}"
}

resource "aws_route_table" "workshop_routing" {
  vpc_id = "${aws_vpc.workshop_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.workshop_igw.id}"
  }
}

resource "aws_main_route_table_association" "workshop_routing_a" {
  vpc_id = "${aws_vpc.workshop_vpc.id}"
  route_table_id = "${aws_route_table.workshop_routing.id}"
}
