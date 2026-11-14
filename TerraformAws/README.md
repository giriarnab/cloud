# AWS Resource creation using Terraform (Infrastructure as Code) 

1. Create Policy, IAM, S3 
2. Create a Lambda function 
3. Create HTTP API Gateway
   - curl "$(terraform output -raw api_http_url)/greet?Name=Arnab"
4. Create REST API Gateway
   - curl "$(terraform output -raw api_rest_url)/greet?Name=Arnab"
