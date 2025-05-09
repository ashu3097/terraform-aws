# main.tf
# This file defines the AWS S3 bucket resource.

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(
    {
      Name = var.bucket_name
    },
    var.tags
  )
}

resource "aws_s3_bucket_acl" "this" {
  count  = var.acl != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  acl    = var.acl
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.enable_versioning != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.enable_server_side_encryption ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_master_key_id : null
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.block_public_access != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = lookup(var.block_public_access, "block_public_acls", true)
  block_public_policy     = lookup(var.block_public_access, "block_public_policy", true)
  ignore_public_acls      = lookup(var.block_public_access, "ignore_public_acls", true)
  restrict_public_buckets = lookup(var.block_public_access, "restrict_public_buckets", true)
}

resource "aws_s3_bucket_logging" "this" {
  count = var.logging != null ? 1 : 0

  bucket = aws_s3_bucket.this.id

  target_bucket = lookup(var.logging, "target_bucket", null)
  target_prefix = lookup(var.logging, "target_prefix", null)
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = lookup(rule.value, "enabled", true) ? "Enabled" : "Disabled"

      filter {
        prefix = lookup(rule.value, "prefix", null)
        # Terraform 0.12 doesn't allow dynamic blocks with for_each inside another dynamic block directly for tags.
        # If specific tag filtering is needed, it's better to define multiple rule blocks or use a more complex structure.
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transitions", [])
        content {
          days          = lookup(transition.value, "days", null)
          date          = lookup(transition.value, "date", null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration", [])
        content {
          days                         = lookup(expiration.value, "days", null)
          date                         = lookup(expiration.value, "date", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transitions", [])
        content {
          noncurrent_days = lookup(transition.value, "noncurrent_days", null)
          storage_class   = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration", [])
        content {
          noncurrent_days = lookup(expiration.value, "noncurrent_days", null)
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = lookup(rule.value, "abort_incomplete_multipart_upload", [])
        content {
          days_after_initiation = lookup(abort_incomplete_multipart_upload.value, "days_after_initiation", null)
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count = length(var.cors_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  count = var.website_configuration != null ? 1 : 0

  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = lookup(var.website_configuration, "index_document", "index.html")
  }

  error_document {
    key = lookup(var.website_configuration, "error_document", "error.html")
  }

  routing_rules = lookup(var.website_configuration, "routing_rules", null)
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = var.object_lock_configuration != null ? 1 : 0

  bucket = aws_s3_bucket.this.id

  object_lock_enabled = "Enabled"

  rule {
    default_retention {
      mode  = lookup(var.object_lock_configuration.default_retention, "mode", null)
      days  = lookup(var.object_lock_configuration.default_retention, "days", null)
      years = lookup(var.object_lock_configuration.default_retention, "years", null)
    }
  }
  # Ensure versioning is enabled if object lock is configured
  depends_on = [aws_s3_bucket_versioning.this]
}
