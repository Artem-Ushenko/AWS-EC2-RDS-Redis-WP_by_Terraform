# Create EC2 instance in public subnet
resource "aws_instance" "ec2" {
  ami             = "ami-080e1f13689e07408"
  instance_type   = "t2.micro"
  key_name        = "wordpress"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.allow_web.id]

  tags = {
    Name = "WordPress"
  }
}

# Create database instance in private subnet
resource "aws_db_instance" "db" {
  identifier           = "wpdbinstance"
  db_name              = "wp_database"
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = random_password.password.result
  parameter_group_name = "default.mysql8.0"

  allocated_storage = 20
  storage_type      = "gp2"

  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
  skip_final_snapshot    = true
}

# Create random password for database
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%+^&*$#!~"
}
