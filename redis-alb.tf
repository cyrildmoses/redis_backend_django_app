# ALB
resource "aws_lb" "redis-app-alb" {
  name               = "webapp-redis-${var.app_name}-${var.stage}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
  #disbled it for now to manage it from terraform
  enable_deletion_protection = false
}

# ALB Target Group
resource "aws_lb_target_group" "redis-app-tg" {
  name        = "ecs-redis-tg-${var.app_name}-${var.stage}"
  port        = var.ecs_task_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/test_connection/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# ALB Listener
resource "aws_lb_listener" "backend_redis_app_listener" {
  load_balancer_arn = aws_lb.redis-app-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis-app-tg.arn
  }
}