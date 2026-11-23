# AWS ECS Fargate Architecture

The editable [AWS architecture diagram](ARCHITECTURE.drawio) uses AWS service icons from the draw.io AWS library. AWS provides approved architecture icons for diagrams and identifies draw.io as a diagramming option on its [architecture icons page](https://aws.amazon.com/architecture/icons/).

The diagram reflects the resources and data lookups in this Terraform project. The project uses the account's default VPC and its subnets. Fargate tasks receive public IP addresses, while the task security group accepts TCP traffic on the configured container port only from the API Gateway VPC Link security group. API Gateway uses the private Cloud Map namespace and service to discover the ECS tasks.

The current task definition targets Linux ARM64 with 256 CPU units and 512 MiB of memory. The configured image is `giriarnab/simple_form:v1`, exposed on TCP port 3000.

The API Gateway HTTP API maps the existing custom domain `greeter.buiz.click` to its auto-deployed `$default` stage. Terraform looks up this domain rather than creating it. API access logs have 30-day retention; container logs have 7-day retention.

## Request and startup paths

- Incoming clients connect directly to the task's public IP on `container_port`; the security group permits that port from any IPv4 address.
- At startup, Fargate uses the task execution role to pull the configured image and deliver container logs to CloudWatch Logs.
- The Terraform configuration does not define an Application Load Balancer, an ECR repository, private subnets, or a NAT gateway. The image URI is supplied through `container_image` and may point to ECR or another registry.

The diagram does not show an internet gateway because it is not managed by this Terraform configuration. Public IP assignment and subnet selection are configured here; internet routing depends on the existing default VPC setup.
