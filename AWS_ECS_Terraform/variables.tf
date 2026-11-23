variable "region" {
  type        = string
  default     = "us-east-2"
  description = "Deployment Region"
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
}

variable "env" {
  type        = string
  description = "Different staging environments"
}

variable "lambda_runtime_node" {
  type        = string
  description = "Node.js runtime for lambda"
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "container_image" {
  description = "Docker image URI (e.g., ECR URI or Docker Hub image)"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Fargate CPU units (256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Fargate memory in MiB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of running tasks"
  type        = number
  default     = 1
}

variable "domain_name" {
  description = "Custom domain name"
  type        = string
}


