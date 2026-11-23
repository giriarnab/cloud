output "vpc_id" {
  description = "ID of the VPC used for the ECS deployment"
  value       = data.aws_vpc.default.id
}

output "security_group_name" {
  description = "Name of the security group attached to the ECS tasks"
  value       = aws_security_group.ecs_tasks.name
}

output "security_group_id" {
  description = "ID of the security group attached to the ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "api_id" {
  description = "Simple Name form API ID"
  value       = aws_apigatewayv2_api.name_form_api.id
}

output "api_endpoint" {
  description = "Simple Name form API Gateway endpoint"
  value       = aws_apigatewayv2_api.name_form_api.api_endpoint
}

# output "custom_domain_api_http_url" {
#   value = "https://${trimsuffix(var.domain_name, ".")}/${aws_apigatewayv2_api_mapping.http_api_mapping.api_mapping_key}"
# }
