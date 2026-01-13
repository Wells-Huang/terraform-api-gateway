# ==========================================
# Outputs
# ==========================================

output "cloudfront_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "api_gateway_invoke_url" {
  description = "API Gateway Invoke URL"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "website_bucket_name" {
  description = "S3 Website Bucket Name"
  value       = aws_s3_bucket.website.bucket
}

output "todo_data_bucket_name" {
  description = "S3 TODO Data Bucket Name"
  value       = aws_s3_bucket.todo_data.bucket
}

output "lambda_function_name" {
  description = "Lambda Function Name"
  value       = aws_lambda_function.todo_api.function_name
}

output "github_actions_access_key_id" {
  description = "GitHub Actions IAM User Access Key ID"
  value       = aws_iam_access_key.github_actions.id
}

output "github_actions_secret_access_key" {
  description = "GitHub Actions IAM User Secret Access Key (Sensitive)"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}

output "website_url" {
  description = "網站 URL (透過 CloudFront)"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}
