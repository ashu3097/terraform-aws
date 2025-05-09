output "application_bucket_id" {
  description = "The ID (name) of the created S3 bucket."
  value       = module.s3_app_bucket.bucket_id
}

output "application_bucket_arn" {
  description = "The ARN of the created S3 bucket."
  value       = module.s3_app_bucket.bucket_arn
}

output "application_bucket_domain_name" {
  description = "The domain name of the created S3 bucket."
  value       = module.s3_app_bucket.bucket_domain_name
}

output "application_bucket_website_endpoint" {
  description = "The website endpoint for the S3 bucket, if configured."
  value       = module.s3_app_bucket.website_endpoint
}