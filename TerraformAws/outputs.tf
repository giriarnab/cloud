output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.greeter.function_name
}

output "api_http_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.http_api_stage.invoke_url
}

output "api_rest_url" {
  value = aws_api_gateway_stage.rest_api_stage.invoke_url
}