# dev.tfvars
# Input values for a DEVELOPMENT environment using the S3 Bucket Terraform Module

# Required variable: Bucket name for the development environment
bucket_name = "my-dev-app-bucket-unique-05092025" # Change to a globally unique name for your dev bucket

# Tags specific to the development environment
tags = {
  Environment = "development"
  Project     = "WebAppX-Dev"
  CostCenter  = "dev-team"
  Terraform   = "true"
}

# ACL for development (default is "private", which is good)
acl = "private"

# Versioning for development (default is true, might disable for dev to save costs if not needed)
enable_versioning = false

# Server-side encryption for development (default is true with AES256)
enable_server_side_encryption = true
sse_algorithm                 = "AES256"
# kms_master_key_id           = null # No specific KMS key for dev unless required

# Block Public Access (defaults are good for keeping dev buckets private)
block_public_access = {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Logging for development (typically disabled or logs to a dev-specific logging bucket)
# logging = {
#   target_bucket = "my-dev-s3-access-logs" # A separate bucket for dev logs
#   target_prefix = "dev-app-bucket-logs/"
# }

# Lifecycle rules for development (might be simpler or non-existent for dev)
lifecycle_rules = [
  {
    id      = "dev-temp-files-expiration"
    enabled = true
    prefix  = "temp/"
    expiration = [{
      days = 15 # Shorter expiration for temp files in dev
    }]
  },
  {
    id      = "dev-incomplete-uploads"
    enabled = true
    abort_incomplete_multipart_upload = [{
      days_after_initiation = 3
    }]
  }
]

# Bucket policy for development (usually null or very restrictive)
# bucket_policy = null

# CORS rules for development (might be more permissive for local development)
# cors_rules = [
#   {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
#     allowed_origins = ["http://localhost:3000", "http://localhost:8080"] # Common local dev servers
#     expose_headers  = ["ETag", "x-amz-version-id"]
#     max_age_seconds = 3000
#   }
# ]

# Static website hosting for development (usually disabled unless testing this feature)
# website_configuration = null

# Object Lock configuration for development (usually disabled)
# object_lock_configuration = null
