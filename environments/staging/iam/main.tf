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
      Component   = "iam"
    }
  }
}



# Create IAM users with bucket-specific permissions
module "iam_users" {
  source = "../../../modules/iam-users"

  environment = var.environment

  user_a_name   = "exif-removal-uploader-${var.environment}"
  bucket_a_name = data.terraform_remote_state.storage.outputs.bucket_a_id
  bucket_a_arn  = data.terraform_remote_state.storage.outputs.bucket_a_arn

  user_b_name   = "exif-removal-reader-${var.environment}"
  bucket_b_name = data.terraform_remote_state.storage.outputs.bucket_b_id
  bucket_b_arn  = data.terraform_remote_state.storage.outputs.bucket_b_arn

  tags = {
    Purpose = "IAM users for bucket access"
  }
}
