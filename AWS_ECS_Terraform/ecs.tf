# CloudWatch Log Group for container logs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7
}

# Security Group allowing inbound traffic to the container port from vpc link
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-ecs-sg"
  description = "Allow inbound access to the Fargate container"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port = var.container_port
    to_port   = var.container_port
    protocol  = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.vpc_link.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

# Fargate Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  # Attach cloudmap to ECS service
  service_registries {
    registry_arn   = aws_service_discovery_service.simple_form_app.arn
    container_name = var.app_name # Must match the name in your task definition
    container_port = 3000         # Must match the port your container listens on
  }
}
