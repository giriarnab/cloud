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
