# 1. Create a Cognito User Pool
resource "aws_cognito_user_pool" "cognito_pool" {
  name = "greeter-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }
}


# 2. Create an App Client (allows password login for testing/apps)
resource "aws_cognito_user_pool_client" "app_client" {
  name         = "greeter-app-client"
  user_pool_id = aws_cognito_user_pool.cognito_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

resource "aws_apigatewayv2_authorizer" "cognito_http" {
  api_id           = aws_apigatewayv2_api.greeter_http_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-jwt-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.app_client.id]
    issuer   = "https://${aws_cognito_user_pool.cognito_pool.endpoint}"
  }
}

resource "aws_api_gateway_authorizer" "cognito_rest" {
  name          = "cognito-rest-authorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.greeter_rest_api.id
  provider_arns = [aws_cognito_user_pool.cognito_pool.arn]
}
