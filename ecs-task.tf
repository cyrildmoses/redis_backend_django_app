#Backend_Redis ECS Task Definition
resource "aws_ecs_task_definition" "redis_ecs_task" {
  family                   = "${var.app_name}-${var.stage}-backend-redis-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.task_execution_iam_role_arn

  container_definitions = jsonencode([{
    name      = "${var.app_name}-${var.stage}-redis-ecs-task"
    image     = var.backend_redis_ecr_image
    cpu       = 256
    memory    = 512
    essential = true
    environment = [
        {
          name  = "CORS_ALLOWED_ORIGINS"
          value = "http://${data.aws_s3_bucket.cloudfront_bucket.website_endpoint},http://${var.cloudfront_endpoint}"
        },
        {
          name  = "REDIS_DB"
          value = "0"
        },
        {
          name  = "REDIS_HOST"
          value = aws_elasticache_cluster.redis.cache_nodes[0].address #split(":", aws_elasticache_cluster.redis.endpoint)[0]
        },
        {
          name  = "REDIS_PORT"
          value = "6379"
        }
      ]
    portMappings = [{
      containerPort = var.ecs_task_port
      hostPort      = var.ecs_task_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.app_name}-${var.stage}-redis-ecs-task"
        "awslogs-region"        = "${var.region}"
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group"  = "true"
        "mode"                  = "non-blocking"
        "max-buffer-size"       = "25m"
      }
    }
  }])

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

}