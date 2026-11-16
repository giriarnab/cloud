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


