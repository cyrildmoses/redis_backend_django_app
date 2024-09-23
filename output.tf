# Output backend_redis ALB URL
output "redis_alb_url" {
  value = "http://${aws_lb.redis-app-alb.dns_name}/test_connection/"
}

