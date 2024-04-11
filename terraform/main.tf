# Create EC2 instance in public subnet
resource "aws_instance" "ec2" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.allow_web.id]

  tags = {
    Name = "WordPress"
  }
}

# Create database instance in private subnet
resource "aws_db_instance" "db" {
  identifier           = "wpdbinstance"
  db_name              = var.db_name
  engine               = "mysql"
  engine_version       = var.db_engine_version
  instance_class       = var.instance_class
  username             = var.db_username
  password             = random_password.password.result
  parameter_group_name = var.db_parameter_group_name

  allocated_storage = var.allocated_storage
  storage_type      = "gp2"

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
  skip_final_snapshot    = true
}

# Create elasticache instance in private subnet
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.cluster_id
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = var.redis_parameter_group_name
  engine_version       = var.redis_engine_version
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet.name
  security_group_ids = [aws_security_group.allow_redis.id]
}

# Create random password for database
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%+^&*$#!~"
}
