variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
  # No default here; this value is expected to come from the .tfvars file.
}

variable "tags" {
  description = "A map of tags to assign to the S3 bucket."
  type        = map(string)
  default     = {} # Default if not specified in .tfvars
}

variable "acl" {
  description = "The canned ACL to apply to the bucket."
  type        = string
  default     = "private" # Default, can be overridden by .tfvars
}

variable "enable_versioning" {
  description = "A boolean that indicates if versioning should be enabled."
  type        = bool
  default     = true # Default, can be overridden by .tfvars
}

variable "enable_server_side_encryption" {
  description = "A boolean that indicates if server-side encryption should be enabled."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use (AES256 or aws:kms)."
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID for SSE-KMS."
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "A map of public access block configurations."
  type = object({
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "logging" {
  description = "S3 bucket logging configuration."
  type = object({
    target_bucket = string
    target_prefix = optional(string)
  })
  default = null # Logging is disabled by default
}

variable "lifecycle_rules" {
  description = "A list of lifecycle rules for the S3 bucket."
  type        = any # Using 'any' for complex objects, or be more specific as in the module
  default     = []
}

variable "bucket_policy" {
  description = "A valid bucket policy JSON document."
  type        = string
  default     = null
}

variable "cors_rules" {
  description = "A list of CORS rules for the S3 bucket."
  type        = any # Using 'any' for complex objects
  default     = []
}

variable "website_configuration" {
  description = "S3 static website hosting configuration."
  type        = any # Using 'any' for complex objects
  default     = null # Static website hosting is disabled by default
}

variable "object_lock_configuration" {
  description = "S3 object lock configuration."
  type        = any # Using 'any' for complex objects
  default     = null # Object lock is disabled by default
}