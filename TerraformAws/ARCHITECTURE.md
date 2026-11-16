# TerraformAws architecture

The editable AWS architecture diagram uses AWS service icons and AWS Cloud, service grouping, and connector conventions. Open [ARCHITECTURE.drawio](ARCHITECTURE.drawio) in diagrams.net (draw.io) to view or edit it.

It depicts API Gateway authorization through Amazon Cognito: the HTTP API uses a JWT authorizer, and the REST API uses a Cognito user-pool authorizer. It also shows the shared Lambda backend and IAM execution role, CloudWatch Logs, and the Route 53 and ACM custom-domain setup in `us-east-2`. Direct API Gateway `execute-api` endpoints are disabled; callers use the custom domain with a Bearer JWT. The commented S3 and IAM examples in `iam.tf` are inactive and are omitted.
