output "public_ip" {
  value = aws_instance.ec2.public_ip
}
output "public_dns" {
  value = aws_instance.ec2.public_dns
}
output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}
output "db_password" {
  value     = random_password.password.result
  sensitive = true
}
output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}
