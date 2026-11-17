# Create the REST API container
resource "aws_api_gateway_rest_api" "greeter_rest_api" {
  name                         = "greeter-rest-api"
  disable_execute_api_endpoint = true
  description                  = "A simple REST API managed by Terraform"
}

# Create a URL path resource (e.g., /greet)
resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.greeter_rest_api.id
  parent_id   = aws_api_gateway_rest_api.greeter_rest_api.root_resource_id
  path_part   = "greet"
}

# Define the HTTP Method (GET /greet)
resource "aws_api_gateway_method" "get_hello" {
  rest_api_id = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = "GET"
  # authorization = "NONE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_rest.id
}

# Configure the Backend Integration with Lambda
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id             = aws_api_gateway_resource.hello_resource.id
  http_method             = aws_api_gateway_method.get_hello.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.greeter.invoke_arn
}

# Define Method and Integration Responses for GET
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.get_hello.http_method
  status_code = "200"
}

# Define the HTTP Method (POST /greet)
resource "aws_api_gateway_method" "post_message" {
  rest_api_id   = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "POST"
  # authorization = "NONE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_rest.id
}

# Direct AWS Service Integration to SQS
resource "aws_api_gateway_integration" "sqs" {
  rest_api_id             = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id             = aws_api_gateway_resource.hello_resource.id
  http_method             = aws_api_gateway_method.post_message.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = aws_iam_role.sqs_exec.arn
  uri                     = "arn:aws:apigateway:${data.aws_region.current.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${split(":", aws_sqs_queue.greet_queue.arn)[5]}"
  passthrough_behavior    = "NEVER"

  # Setting Content-Type to 'application/x-www-form-urlencoded' (note the single quotes inside double quotes)
  # and URL-encoding $input.body prevents special characters or & symbols in JSON payloads from breaking the SQS query string.
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$util.urlEncode($input.body)"
  }
}

# Define Method Responses for POST
resource "aws_api_gateway_method_response" "response_POST_200" {
  rest_api_id = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.post_message.http_method
  status_code = "200"
}

# Define Integration Responses for POST
resource "aws_api_gateway_integration_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.greeter_rest_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.post_message.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  depends_on = [aws_api_gateway_integration.sqs]
}

# Deploy the API and create a Stage (e.g., /prod)
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