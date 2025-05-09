module "s3_app_bucket" {
  source = "./modules/s3_bucket" # Adjust path if your module is in a different location

  # Pass all declared variables to the module.
  # Terraform will use the value from the .tfvars file if provided,
  # otherwise it will use the default value specified in the variable block.
  bucket_name                 = var.bucket_name
  tags                        = var.tags
  acl                         = var.acl
  enable_versioning           = var.enable_versioning
  enable_server_side_encryption = var.enable_server_side_encryption
  sse_algorithm               = var.sse_algorithm
  kms_master_key_id           = var.kms_master_key_id
  block_public_access         = var.block_public_access
  logging                     = var.logging
  lifecycle_rules             = var.lifecycle_rules
  bucket_policy               = var.bucket_policy
  cors_rules                  = var.cors_rules
  website_configuration       = var.website_configuration
  object_lock_configuration   = var.object_lock_configuration
}