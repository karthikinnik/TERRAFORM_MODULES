# vpc creation
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "VPC-${var.customer_name}"
  }
}

#elastic ip creation
resource "aws_eip" "eip_nat" {
   tags = {
    Name = "EIP-${var.customer_name}"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW-${var.customer_name}"
  }
}

# Nat gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "NGW-${var.customer_name}"
  }
}

# Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PUBLIC-RT-${var.customer_name}"
  }
}

# Private route table
resource "aws_default_route_table" "private_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "MAIN/PRIVATE-RT-${var.customer_name}"
  }
}

# Public sunbet
resource "aws_subnet" "public_subnet" {
  cidr_block              = var.public_cidr
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"
  tags = {
    Name = "PUBLIC-SN-${var.customer_name}"
  }
}

# Private subnet
resource "aws_subnet" "private_subnet" {
  cidr_block        = var.private_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-1b"
  tags = {
    Name = "PRIVATE-SN-${var.customer_name}"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
  depends_on     = [aws_route_table.public_route_table, aws_subnet.public_subnet]
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_subnet_assoc" {
  route_table_id = aws_default_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet.id
  depends_on     = [aws_default_route_table.private_route_table, aws_subnet.private_subnet]
}

#Public ingress rule
resource "aws_security_group" "public_dynamic_sg" {
    name = "PUBLIC-SG-${var.customer_name}"
    vpc_id = aws_vpc.vpc.id
   dynamic "ingress" {
     for_each = var.public_ingress_ports
     content {
       from_port = ingress.value
       to_port = ingress.value
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
   }
}

#Public egress rule
resource "aws_security_group_rule" "outbound-public" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.public_dynamic_sg.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}