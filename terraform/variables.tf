########### AWS variables
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

########### Database variables
variable "db_name" {
  type    = string
  default = "wp_database"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_engine_version" {
  description = "MySQL engine version"
  default     = "8.0.28"
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  default     = 20
}

variable "db_parameter_group_name" {
  description = "The name of the parameter group to associate with the database"
  default     = "default.mysql8.0"
}

########### EC2 variables
variable "ami_id" {
  type    = string
  default = "ami-080e1f13689e07408"
}

variable "key_name" {
  type    = string
  default = "wordpress"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

########### Redis variables
variable "cluster_id" {
  description = "Identifier for the ElastiCache cluster"
  type        = string
  default     = "redis-cluster"
}

variable "node_type" {
  description = "The node type of the Redis cluster"
  default     = "cache.m4.large"
}

variable "redis_engine_version" {
  description = "The version of the Redis engine to use"
  default     = "7.1"
}

variable "redis_parameter_group_name" {
  description = "The name of the parameter group to associate with the cluster"
  default     = "default.redis7"
}