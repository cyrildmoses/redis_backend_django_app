resource "aws_elasticache_subnet_group" "example" {
  name       = "redis-subnet-group-${var.app_name}-${var.stage}"
  subnet_ids  = var.private_subnet_ids # Replace with your subnet IDs
}

resource "aws_security_group" "redis_sg" {
  name = "redis-sg-${var.app_name}-${var.stage}"
  description = "Security group for Redis cluster"
  vpc_id = var.vpc_id # Replace with your VPC ID

  ingress {
    description = "Allow incoming traffic from ECS tasks on port 6379 for redis database access"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [data.aws_security_group.ecs_sg.id]
  }

  egress {
    description = "Allows all outbound traffic to all IP addresses on all ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster-${var.app_name}-${var.stage}"
  node_type             = "cache.t3.micro" # Choose an instance type
  engine                = "redis"
  num_cache_nodes       = 1
  parameter_group_name  = "default.redis7"
  port                  = 6379
  availability_zone = "${var.region}a"
  #preferred_maintenance_window = "sun:05:00-sun:09:00" # Set your preferred maintenance window

  subnet_group_name = aws_elasticache_subnet_group.example.name
  security_group_ids = [aws_security_group.redis_sg.id]
}