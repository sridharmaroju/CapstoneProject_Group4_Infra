output "api_invoke_url" {
  description = "API Invoke URL."
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/${local.workspace_safe}"
}

output "api_invoke_custom_url" {
  description = "API Invoke Custom URL."
  value       = "https://api.${var.name_prefix}.${local.workspace_safe}.${var.domain}/${local.workspace_safe}"
}

output "cloudfront_distribution_id" {
  description = "Cloudfront Distribution ID."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cognito_user_pool_id" {
  description = "The unique ID of the AWS Cognito User Pool."
  value       = aws_cognito_user_pool.user_pool.id
}

output "cognito_user_pool_client_id" {
  description = "The Client ID for the Angular application (User Pool App Client ID)."
  value       = aws_cognito_user_pool_client.app.id
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket created for static frontend hosting."
  value       = aws_s3_bucket.static_bucket.bucket
}

output "website_url" {
  description = "Front End Website URL"
  value       = "https://${var.name_prefix}.${local.workspace_safe}.${var.domain}"
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "rds_port" {
  value = aws_db_instance.mysql.port
}

output "secret_arn" {
  value = aws_secretsmanager_secret.mysql.arn
}