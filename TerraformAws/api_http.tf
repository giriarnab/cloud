resource "aws_apigatewayv2_api" "greeter_http_api" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
  description = "A simple HTTP API managed by Terraform"
}

resource "aws_apigatewayv2_stage" "http_api_stage" {
  api_id = aws_apigatewayv2_api.greeter_http_api.id

  name        = "serverless_lambda_test_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "greeter" {
  api_id = aws_apigatewayv2_api.greeter_http_api.id

  integration_uri    = aws_lambda_function.greeter.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "greeter" {
  api_id = aws_apigatewayv2_api.greeter_http_api.id

  route_key = "GET /greet"
  target    = "integrations/${aws_apigatewayv2_integration.greeter.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.greeter_http_api.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.greeter.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.greeter_http_api.execution_arn}/*/*"
}