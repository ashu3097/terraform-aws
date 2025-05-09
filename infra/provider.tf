terraform {
  backend "s3" {
    bucket         = "terraform-003-tfsate" # REPLACE with your S3 bucket name for storing state
    key            = "global/s3_module/terraform.tfstate" # Path to the state file in the S3 bucket
    region         = "eu-central-1"                         # The region of your S3 bucket and DynamoDB table
    dynamodb_table = "terraform-lock-table"   # REPLACE with your DynamoDB table name for state locking
    encrypt        = true                                 # Encrypts the state file in S3
  }
}


provider "aws" {
  region = "ap-south-1" # Specify your desired AWS region
}