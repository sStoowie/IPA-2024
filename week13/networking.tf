locals {
  default_tags = {
    itclass = "IPA24"
    itgroup = "year3"
  }
}

resource "aws_vpc" "testVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-testVPC"
  })
}

resource "aws_internet_gateway" "testIGW" {
  vpc_id = aws_vpc.testVPC.id
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-testIGW"
  })
}

resource "aws_subnet" "Public1" {
  vpc_id                  = aws_vpc.testVPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.testIGW]
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-Public1"
  })
}

resource "aws_subnet" "Public2" {
  vpc_id                  = aws_vpc.testVPC.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.testIGW]
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-Public2"
  })
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.testVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.testIGW.id
  }
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-PublicRouteTable"
  })
}

resource "aws_route_table_association" "Public1RouteTableAssociation" {
  subnet_id      = aws_subnet.Public1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "Public2RouteTableAssociation" {
  subnet_id      = aws_subnet.Public2.id
  route_table_id = aws_route_table.PublicRouteTable.id
}
