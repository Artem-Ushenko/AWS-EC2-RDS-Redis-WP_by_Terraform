output "public_ip" {
  value = aws_instance.ec2.public_ip
}
output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}
