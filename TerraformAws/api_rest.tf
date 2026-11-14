data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# 1. Create the REST API container
resource "aws_api_gateway_rest_api" "greeter_rest_api" {
  name        = "greeter-rest-api"
  description = "A simple REST API managed by Terraform"
}

# 2. Create a URL path resource (e.g., /greet)
resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.greeter_rest_api.id
  parent_id   = aws_api_gateway_rest_api.greeter_rest_api.root_resource_id
  path_part   = "greet"
}

# 3. Define the HTTP Method (GET /greet)
resource "aws_api_gateway_method" "get_hello" {
  rest_api_id   = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# 4. Configure the Backend Integration (Mock response for testing)
# resource "aws_api_gateway_integration" "mock_integration" {
#   rest_api_id = aws_api_gateway_rest_api.greeter_api.id
#   resource_id = aws_api_gateway_resource.hello_resource.id
#   http_method = aws_api_gateway_method.get_hello.http_method
#   type        = "MOCK"
#
#   request_templates = {
#     "application/json" = jsonencode({ statusCode = 200 })
#   }
# }

# 4. Configure the Backend Integration with Lambda
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id             = aws_api_gateway_resource.hello_resource.id
  http_method             = aws_api_gateway_method.get_hello.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.greeter.invoke_arn
}

# 5. Define Method and Integration Responses
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.get_hello.http_method
  status_code = "200"
}

# 6. Deploy the API and create a Stage (e.g., /prod)
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.greeter_rest_api.id

  triggers = {
    # Forces a new deployment on every terraform apply
    redeployment = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.greeter_rest_api.id
  stage_name    = "test"
}

resource "aws_lambda_permission" "greeter_api_gw" {
  statement_id  = "AllowExecutionFromRESTAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.greeter.function_name
  principal     = "apigateway.amazonaws.com"

  # source_arn = "arn:aws:execute-api:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.greeter_api.id}/*/${aws_api_gateway_method.get_hello.http_method}${aws_api_gateway_resource.hello_resource.path}"
  source_arn = "arn:${data.aws_partition.current.partition}:execute-api:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.greeter_rest_api.id}/*/${aws_api_gateway_method.get_hello.http_method}${aws_api_gateway_resource.hello_resource.path}"
  # source_arn = "${aws_api_gateway_rest_api.greeter_rest_api.execution_arn}/*"
}