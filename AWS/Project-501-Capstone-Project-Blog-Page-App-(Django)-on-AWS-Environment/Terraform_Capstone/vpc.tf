resource "aws_vpc" "aws_capstone_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "aws_capstone_vpc"
  }
}

resource "aws_subnet" "aws_capstone_vpc_public_subnet_A" {
  vpc_id     = aws_vpc.aws_capstone_vpc.id
  cidr_block = var.public_subnet_A_cidr
  availability_zone = "${local.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "aws_capstone_vpc_public_subnet_A"
  }
}

resource "aws_subnet" "aws_capstone_vpc_public_subnet_B" {
  vpc_id     = aws_vpc.aws_capstone_vpc.id
  cidr_block = var.public_subnet_B_cidr
  availability_zone = "${local.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "aws_capstone_vpc_public_subnet_B"
  }
}

resource "aws_subnet" "aws_capstone_vpc_private_subnet_A" {
  vpc_id     = aws_vpc.aws_capstone_vpc.id
  cidr_block = var.private_subnet_A_cidr
  availability_zone = "${local.region}a"
  tags = {
    Name = "aws_capstone_vpc_private_subnet_A"
  }
}

resource "aws_subnet" "aws_capstone_vpc_private_subnet_B" {
  vpc_id     = aws_vpc.aws_capstone_vpc.id
  cidr_block = var.private_subnet_B_cidr
  availability_zone = "${local.region}b"

  tags = {
    Name = "aws_capstone_vpc_private_subnet_B"
  }
}

resource "aws_internet_gateway" "aws_capstone_vpc_igw" {
  vpc_id = aws_vpc.aws_capstone_vpc.id

  tags = {
    Name = "aws_capstone_vpc_igw"
  }
}

resource "aws_route_table" "aws_capstone_vpc_public_RT" {
  vpc_id = aws_vpc.aws_capstone_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_capstone_vpc_igw.id
  }

  tags = {
    Name = "aws_capstone_vpc_public_RT"
  }
}

resource "aws_route_table" "aws_capstone_vpc_private_RT" {
  vpc_id = aws_vpc.aws_capstone_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Nat_gw.id
  }

  tags = {
    Name = "aws_capstone_vpc_private_RT"
  }
}

resource "aws_route_table_association" "public_A_assos" {
  subnet_id      = aws_subnet.aws_capstone_vpc_public_subnet_A.id
  route_table_id = aws_route_table.aws_capstone_vpc_public_RT.id
}

resource "aws_route_table_association" "public_B_assos" {
  subnet_id      = aws_subnet.aws_capstone_vpc_public_subnet_B.id
  route_table_id = aws_route_table.aws_capstone_vpc_public_RT.id
}

resource "aws_route_table_association" "private_A_assos" {
  subnet_id      = aws_subnet.aws_capstone_vpc_private_subnet_A.id
  route_table_id = aws_route_table.aws_capstone_vpc_private_RT.id
}

resource "aws_route_table_association" "private_B_assos" {
  subnet_id      = aws_subnet.aws_capstone_vpc_private_subnet_B.id
  route_table_id = aws_route_table.aws_capstone_vpc_private_RT.id
}

resource "aws_eip" "aws_capstone_vpc_eip" {
  vpc      = true
}

resource "aws_nat_gateway" "Nat_gw" {
  allocation_id = aws_eip.aws_capstone_vpc_eip.id
  subnet_id     = aws_subnet.aws_capstone_vpc_public_subnet_A.id
  depends_on    = [aws_internet_gateway.aws_capstone_vpc_igw]

  tags = {
    Name = "NAT Gateway"
  }
}

# Declare the data source
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.aws_capstone_vpc.id
  service_name = "com.amazonaws.${local.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "private_route_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.aws_capstone_vpc_private_RT.id
}


resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = var.key_pair
  vpc_security_group_ids = [aws_security_group.aws_capstone_bastion_host_sec_grp.id]
  subnet_id = aws_subnet.aws_capstone_vpc_public_subnet_A.id

  tags = {
    Name = "aws_capstone_bastion_host"
  }
}