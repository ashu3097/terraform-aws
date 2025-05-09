variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the S3 bucket."
  type        = map(string)
  default     = {}
}

variable "acl" {
  description = "The canned ACL to apply to the bucket. Valid values: private, public-read, public-read-write, aws-exec-read, authenticated-read, log-delivery-write."
  type        = string
  default     = "private" # Recommended default
  validation {
    condition     = var.acl == null || contains(["private", "public-read", "public-read-write", "aws-exec-read", "authenticated-read", "log-delivery-write"], var.acl)
    error_message = "Invalid ACL value. Must be one of: private, public-read, public-read-write, aws-exec-read, authenticated-read, log-delivery-write."
  }
}

variable "enable_versioning" {
  description = "A boolean that indicates if versioning should be enabled for the S3 bucket."
  type        = bool
  default     = true
}

variable "enable_server_side_encryption" {
  description = "A boolean that indicates if server-side encryption should be enabled."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 or aws:kms."
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "Invalid SSE algorithm. Must be AES256 or aws:kms."
  }
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This is required if sse_algorithm is aws:kms."
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "A map of public access block configurations. All default to true."
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
  description = "A map of S3 bucket logging configuration."
  type = object({
    target_bucket = string
    target_prefix = optional(string)
  })
  default = null # Logging is disabled by default
}

variable "lifecycle_rules" {
  description = "A list of lifecycle rules for the S3 bucket."
  type = list(object({
    id      = string
    enabled = optional(bool, true)
    prefix  = optional(string)
    tags    = optional(map(string)) # Note: direct tag filtering in dynamic blocks can be tricky.

    transitions = optional(list(object({
      days          = optional(number)
      date          = optional(string)
      storage_class = string
    })), [])

    expiration = optional(list(object({
      days                         = optional(number)
      date                         = optional(string)
      expired_object_delete_marker = optional(bool)
    })), [])

    noncurrent_version_transitions = optional(list(object({
      noncurrent_days = optional(number)
      storage_class   = string
    })), [])

    noncurrent_version_expiration = optional(list(object({
      noncurrent_days = optional(number)
    })), [])

    abort_incomplete_multipart_upload = optional(list(object({
      days_after_initiation = optional(number)
    })), [])
  }))
  default = []
}

variable "bucket_policy" {
  description = "A valid bucket policy JSON document. Note: Ensure this policy does not conflict with block_public_access settings."
  type        = string
  default     = null
}

variable "cors_rules" {
  description = "A list of CORS rules for the S3 bucket."
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "website_configuration" {
  description = "A map of S3 static website hosting configuration."
  type = object({
    index_document = optional(string, "index.html")
    error_document = optional(string, "error.html")
    routing_rules  = optional(string) # JSON string for routing rules
  })
  default = null # Static website hosting is disabled by default
}

variable "object_lock_configuration" {
  description = "A map of S3 object lock configuration. Versioning must be enabled."
  type = object({
    default_retention = object({
      mode  = string # Valid values are GOVERNANCE or COMPLIANCE
      days  = optional(number)
      years = optional(number)
    })
  })
  default = null # Object lock is disabled by default
  # Validation: If object_lock_configuration is set, enable_versioning must be true.
  # This validation is implicitly handled by the depends_on in the resource.
}