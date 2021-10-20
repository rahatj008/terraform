provider "aws" {
    region                  = "us-west-2"
    shared_credentials_file = "C:\\Users\\Waqar Ali\\.aws\\creds"
    profile                 = "breakout"
}

terraform {
  backend "s3" {
    bucket         = "terraform-breakout"
    key            = "data/vpc/terraform.tfstate"
    region         = "us-west-2"
  }
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "custom_igw"
  }
}

output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}

resource "aws_security_group" "custom_public_sg" {
  name = "CustomSGPublic"
  description = "Allow ssh"
  vpc_id = aws_vpc.custom_vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 9022
    to_port = 9022
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
}

resource "aws_security_group" "custom_instances_sg" {
  name = "CustomSG"
  description = "CustomLiveSiteSecurityGroup"
  vpc_id = aws_vpc.custom_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 9022
    to_port     = 9022
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

}

resource "aws_subnet" "mgmt_subnet" {
   cidr_block = var.vpc_cidr_mgmt
   vpc_id = aws_vpc.custom_vpc.id
   tags = {
    Name = "MGMT"
   }
}

resource "aws_subnet" "public_2a" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.pub_cidr2a
  availability_zone = "us-west-2a"
  tags = {
    Name = "custom_pub_net_2a"
  }
}

resource "aws_subnet" "public_2b" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.pub_cidr2b
  availability_zone = "us-west-2b"
  tags = {
    Name = "custom_pub_net_2b"
  }
}

resource "aws_subnet" "nlb_2a" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.nlb_cidr2a
  availability_zone = "us-west-2a"
  tags = {
    Name = "nlb_pub_net_2a"
  }
}

resource "aws_subnet" "nlb_2b" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.nlb_cidr2b
  availability_zone = "us-west-2b"
  tags = {
    Name = "nlb_pub_net_2b"
  }
}

resource "aws_db_subnet_group" "rds_subnet" {
  name = "custom_rds_subnet"
  subnet_ids = [aws_subnet.rds_subnet_2a.id,aws_subnet.rds_subnet_2b.id]
}

resource "aws_subnet" "rds_subnet_2a" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.rds_subnet1
  availability_zone = "us-west-2a"
  tags = {
    Name = "custom_rds_net_2a"
  }
}

resource "aws_subnet" "rds_subnet_2b" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.rds_subnet2
  availability_zone = "us-west-2b"
  tags = {
    Name = "custom_rds_net_2b"
  }
}


# Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }
  tags = {
    Name = "custom_pub_rt"
  }
}


# Route table: nat Gateway A
resource "aws_route_table" "nat_rt_a" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_b.id
  }
  tags = {
    Name = "custom_nat_rt_a"
  }
}
# Route table: nat Gateway B
resource "aws_route_table" "nat_rt_b" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_b.id
  }
  tags = {
    Name = "custom_nat_rt_b"
  }
}

# Route table association with public subnets

resource "aws_route_table_association" "custom_public" {
    subnet_id = aws_subnet.mgmt_subnet.id
    route_table_id = aws_route_table.public_rt.id
}


# Route table association with ec2 subnets

resource "aws_route_table_association" "custom_vpc_2a_net" {
    subnet_id = aws_subnet.public_2a.id
    route_table_id = aws_route_table.nat_rt_a.id
}

resource "aws_route_table_association" "custom_vpc_2b_net" {
    subnet_id = aws_subnet.public_2b.id
    route_table_id = aws_route_table.nat_rt_b.id
}

# Route table association with nlb subnets

resource "aws_route_table_association" "custom_nlb_2a_net" {
    subnet_id = aws_subnet.nlb_2a.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "custom_nlb_2b_net" {
    subnet_id = aws_subnet.nlb_2b.id
    route_table_id = aws_route_table.public_rt.id
}

############### NAT GW A B ####################

resource "aws_eip" "nat_a" {
  vpc = true
}
resource "aws_eip" "nat_b" {
  vpc = true
}

resource "aws_nat_gateway" "natgw_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.nlb_2a.id
  tags = {
    Name = "gw NAT A"
  }
}
resource "aws_nat_gateway" "natgw_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.nlb_2b.id
  tags = {
    Name = "gw NAT B"
  }
}