#Creates a private DNS namespace and registers your ECS tasks automatically so API Gateway can find them
resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name        = "ecs.internal"
  description = "Private DNS namespace for ECS services"
  vpc         = data.aws_vpc.default.id
}

resource "aws_service_discovery_service" "simple_form_app" {
  name = "${var.app_name}-discovery_service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs.id

    dns_records {
      ttl  = 10
      type = "SRV" # Required for API Gateway VPC Link integration
    }

    routing_policy = "MULTIVALUE"
  }

  # health_check_config {
  #   failure_threshold = 1
  # }
}

resource "aws_security_group" "vpc_link" {
  name   = "apigw-vpc-link-sg"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
