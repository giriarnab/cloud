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

output "custom_domain_api_http_url" {
  value = "https://${trimsuffix(aws_route53_record.api_dns.fqdn, ".")}/${aws_apigatewayv2_api_mapping.http_api_mapping.api_mapping_key}"
}

output "custom_domain_api_rest_url" {
  value = "https://${trimsuffix(aws_route53_record.api_dns.fqdn, ".")}/${aws_api_gateway_base_path_mapping.rest_api_mapping.base_path}"
}