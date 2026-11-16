# 1. Look up your existing Route 53 Hosted Zone
data "aws_route53_zone" "r53_public_zone" {
  name         = "buiz.click"
  private_zone = false
}

# 2. Request an SSL Certificate from ACM
resource "aws_acm_certificate" "api_cert" {
  domain_name       = "greeter.buiz.click"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Create DNS records to validate the ACM certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.r53_public_zone.zone_id
}

# 4. Wait for the certificate validation to complete
resource "aws_acm_certificate_validation" "api_cert" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# 5. Create the Custom Domain Name in API Gateway (v2)
resource "aws_apigatewayv2_domain_name" "api_domain" {
  domain_name = "greeter.buiz.click"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.api_cert.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# 6. Map the custom domain to your HTTP API Gateway stage
resource "aws_apigatewayv2_api_mapping" "http_api_mapping" {
  api_id          = aws_apigatewayv2_api.greeter_http_api.id
  api_mapping_key = "http-api"
  domain_name     = aws_apigatewayv2_domain_name.api_domain.id
  stage           = aws_apigatewayv2_stage.http_api_stage.id
}

# 6. Map the Custom Domain to your REST API Gateway Stage
resource "aws_api_gateway_base_path_mapping" "rest_api_mapping" {
  api_id      = aws_api_gateway_rest_api.greeter_rest_api.id
  base_path   = "rest-api"
  domain_name = aws_apigatewayv2_domain_name.api_domain.domain_name
  stage_name  = aws_api_gateway_stage.rest_api_stage.stage_name
}

# 7. Point your Route 53 domain to the API Gateway target domain
resource "aws_route53_record" "api_dns" {
  name    = aws_apigatewayv2_domain_name.api_domain.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.r53_public_zone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
