resource "aws_vpc" "global_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.environment}-${local.project}-vpc"
  }
}
resource "aws_subnet" "global_public_subnet_a" {
  vpc_id            = aws_vpc.global_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${local.region}a"
  tags = {
    Name = "${local.environment}-${local.project}-public-subnet-a"
  }
}
resource "aws_subnet" "global_public_subnet_b" {
  vpc_id            = aws_vpc.global_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${local.region}b"
  tags = {
    Name = "${local.environment}-${local.project}-public-subnet-b"
  }
}
resource "aws_route_table" "global_rt" {
  vpc_id = aws_vpc.global_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.global_igw.id
  }

  tags = {
    Name = "${local.environment}-${local.project}-rt"
  }
}

resource "aws_route_table_association" "global_subnetA_rt_association" {
  subnet_id      = aws_subnet.global_public_subnet_a.id
  route_table_id = aws_route_table.global_rt.id
}
resource "aws_route_table_association" "global_subnetB_rt_association" {
  subnet_id      = aws_subnet.global_public_subnet_b.id
  route_table_id = aws_route_table.global_rt.id
}

resource "aws_security_group" "global_sg" {
  name        = "${local.environment}-${local.project}-vpc-sg"
  description = "Allow SSH and HTTP from anywhere"
  vpc_id      = aws_vpc.global_vpc.id
}
resource "aws_vpc_security_group_ingress_rule" "global_sg_allow_ssh" {
  security_group_id = aws_security_group.global_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_ingress_rule" "global_sg_allow_http" {
  security_group_id = aws_security_group.global_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_ingress_rule" "global_sg_allow_https" {
  security_group_id = aws_security_group.global_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_ingress_rule" "global_sg_allow_kubernetes" {
  security_group_id = aws_security_group.global_sg.id
  description       = "kubernetes"
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_egress_rule" "global_sg_allow_all" {
  security_group_id = aws_security_group.global_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_internet_gateway" "global_igw" {
  vpc_id = aws_vpc.global_vpc.id
  tags = {
    Name = "${local.environment}-${local.project}-igw"
  }
}