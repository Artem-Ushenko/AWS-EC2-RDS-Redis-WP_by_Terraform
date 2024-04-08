resource "aws_instance" "ec2" {
  ami             = "ami-080e1f13689e07408" # Update this with the latest Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  key_name        = "D:\\abz\\.credentials\\wordpress.pem" # Ensure you have this key pair created
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.allow_web.name]

  tags = {
    Name = "WordPress"
  }
}


resource "aws_db_instance" "db" {
  identifier           = "wpdbinstance"
  db_name              = "wp_database"
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.t3.micro"
  username             = "wordpressuseradmin"
  password             = "wordpressuserp@ssword123"
  parameter_group_name = "default.mysql8.0"

  allocated_storage = 20
  storage_type      = "gp2"

  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
  skip_final_snapshot    = true
}
