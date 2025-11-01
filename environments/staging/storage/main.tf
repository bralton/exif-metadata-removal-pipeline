terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "exif-removal"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "storage"
    }
  }
}

# Bucket A - Upload bucket (publicly accessible for uploads)
module "bucket_a" {
  source = "../../../modules/s3-bucket"

  bucket_name                      = "${var.environment}-bucket-a"
  environment                      = var.environment
  enable_versioning                = true
  block_public_access              = false # Public access for uploads
  enable_eventbridge_notifications = true  # Required for Lambda trigger


  lifecycle_rules = [
    {
      id              = "delete-old-uploads"
      enabled         = true
      prefix          = ""
      expiration_days = 90 # Clean up old uploads after 90 days, which should be sufficient for processing
    }
  ]

  # Potentially add CORS configuration if needed for web uploads ONLY from website.

  tags = {
    Purpose = "Upload bucket for raw images with EXIF data"
  }
}

# Bucket B - Sanitized bucket (private)
module "bucket_b" {
  source = "../../../modules/s3-bucket"

  bucket_name                      = "${var.environment}-bucket-b"
  environment                      = var.environment
  enable_versioning                = true
  block_public_access              = true # Private bucket
  enable_eventbridge_notifications = false

  # Move to colder storage classes over time to save costs
  lifecycle_rules = [
    {
      id      = "transition-to-glacier"
      enabled = true
      prefix  = ""
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  tags = {
    Purpose = "Sanitized bucket for images with EXIF removed"
  }
}
