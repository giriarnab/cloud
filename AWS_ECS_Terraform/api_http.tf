resource "aws_apigatewayv2_vpc_link" "ecs" {
  name               = "ecs-vpc-link"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = data.aws_subnets.default.ids
}

resource "aws_apigatewayv2_api" "name_form_api" {
  name                         = "${var.app_name}-http-api"
  protocol_type                = "HTTP"
  # disable_execute_api_endpoint = true
  description                  = "Simple Name form HTTP API managed by Terraform"
}

resource "aws_apigatewayv2_integration" "ecs" {
  api_id             = aws_apigatewayv2_api.name_form_api.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.ecs.id
  integration_uri    = aws_service_discovery_service.simple_form_app.arn
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.name_form_api.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.ecs.id}"
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.name_form_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.ecs.id}"
}

resource "aws_apigatewayv2_stage" "http_api_stage" {
  api_id      = aws_apigatewayv2_api.name_form_api.id
  name        = "$default"
  auto_deploy = true
}

data "aws_api_gateway_domain_name" "this" {
  domain_name = "greeter.buiz.click"
}

# Map API Gateway to custom domain
resource "aws_apigatewayv2_api_mapping" "http_api_mapping" {
  api_id          = aws_apigatewayv2_api.name_form_api.id
  # api_mapping_key = "form"
  domain_name     = data.aws_api_gateway_domain_name.this.id
  stage           = aws_apigatewayv2_stage.http_api_stage.id
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.name_form_api.name}"
  retention_in_days = 30
}

