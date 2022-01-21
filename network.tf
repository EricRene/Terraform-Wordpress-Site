////////////////////////////////////
// ------------ VPC ------------ //
//////////////////////////////////

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  #test set to true
  enable_dns_hostnames = "true"
  #added to test vpc endpoint
  enable_dns_support     = "true"

  tags = {
    Name = "Final Demo VPC"
  }
}

////////////////////////////////////////
// ------------ Subnets ------------ //
//////////////////////////////////////


resource "aws_subnet"  "public_subnets" {
  count                   = 2

  cidr_block              = "192.168.${count.index}.0/24"
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = tomap({ "Name" = "${var.public_subnet_names[count.index]}" })
}

resource "aws_subnet"  "web_server_subnets" {
  count                   = 2

  cidr_block              = "192.168.${2+count.index}.0/24"
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = tomap({ "Name" = "${var.web_server_subnet_names[count.index]}" })
}

resource "aws_subnet"  "database_subnets" {
  count                   = 2

  cidr_block              = "192.168.${4+count.index}.0/24"
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = tomap({ "Name" = "${var.database_subnet_names[count.index]}" })
}

//////////////////////////////////////////////////
// ------------ Internet Gateway ------------ //
//////////////////////////////////////////////

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Final Demo Internet Gateway"
  }
}

//////////////////////////////////////////////
// ------------ Route Tables ------------ //
//////////////////////////////////////////

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private_route_table"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "Public_route_table"
  }
}

////////////////////////////////////////////////////////
// ------------ Route Table Association ------------ //
//////////////////////////////////////////////////////


resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = "${aws_subnet.public_subnets.*.id[count.index]}"
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "web_server_route_table_association" {
  count = 2

  subnet_id      = "${aws_subnet.web_server_subnets.*.id[count.index]}"
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "database_route_table_association" {
  count = 2

  subnet_id      = "${aws_subnet.database_subnets.*.id[count.index]}"
  route_table_id = aws_route_table.private_route_table.id
}

////////////////////////////////////////////
// ------------ NAT Gateway ------------ //
//////////////////////////////////////////

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "Final Demo NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my_igw]
}

///////////////////////////////////////////
// ------------ Elastic IP ------------ //
/////////////////////////////////////////


resource "aws_eip" "nat_gw_eip" {
  vpc      = true

  depends_on = [aws_internet_gateway.my_igw]
}
