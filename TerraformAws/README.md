# AWS Resource creation using Terraform (Infrastructure as Code) 

See the [AWS architecture diagram](ARCHITECTURE.drawio) (editable in diagrams.net).

1. Create Policy, IAM, S3 
2. Create a Lambda function 
3. Create HTTP API Gateway
   - curl "$(terraform output -raw api_http_url)/greet?Name=Arnab"
4. Create REST API Gateway
     - curl "$(terraform output -raw api_rest_url)/greet?Name=Arnab"
5. Create Custom Domain Name
   - Buy domain name from Domain Registerer
   - Create DNS Zone using custom domain name in Route 53
   - Request an SSL Certificate from ACM
   - Create DNS records to validate the ACM certificate. 
   - Create the Custom Domain Name in API Gateway 
   - Map the custom domain to your API Gateway stage for HTTP & Rest API .Test using below script from CLI
     - curl "$(terraform output -raw custom_domain_api_http_url)/greet?Name=Arnab"
     - curl "$(terraform output -raw custom_domain_api_rest_url)/greet?Name=Arnab"
   - Disable direct access to APIGateway by setting below property of API Gateway
     - disable_execute_api_endpoint = true

![img.png](img.png)