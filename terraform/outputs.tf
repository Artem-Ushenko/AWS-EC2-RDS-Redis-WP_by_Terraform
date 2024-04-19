# Output EC2 instance public
output "public_ip" {
  value = aws_instance.ec2.public_ip
}
output "public_dns" {
  value = aws_instance.ec2.public_dns
}

# Output database
output "db_name" {
  value = aws_db_instance.db.db_name
  sensitive = true
}
output "db_endpoint" {
  value     = split(":", aws_db_instance.db.endpoint)[0]
  sensitive = true
}
output "db_username" {
  value     = aws_db_instance.db.username
  sensitive = true
}
output "db_password" {
  value     = random_password.password.result
  sensitive = true
}

# Output redis
output "redis_endpoint" {
  value     = aws_elasticache_cluster.redis.cache_nodes.0.address
  sensitive = true
}
