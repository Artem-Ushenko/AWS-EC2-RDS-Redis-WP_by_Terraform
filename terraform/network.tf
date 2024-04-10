# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "Main VPC"
  }
}

############################################################### Create subnets

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b" # Update for each AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet"
  }
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-east-1a" # Update for each AZ

  tags = {
    Name = "Private subnet"
  }
}

# Create DB subnet
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.public_subnet.id]

  tags = {
    Name = "DB subnet"
  }
}

# Create elasticache subnet
resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "RedisSubnet"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.public_subnet.id]

  tags = {
    Name = "Redis subnet"
  }
}

############################################################### Create internet gateway

# Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

############################################################### Create route tables

# Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Associate public route table with public subnet
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = aws_vpc.main_vpc.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Associate private route table with private subnet
resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
