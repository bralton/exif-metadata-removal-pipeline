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
      Component   = "exif-pipeline"
    }
  }
}



# Deploy Lambda function for EXIF removal
module "exif_remover" {
  source = "../../../modules/lambda-exif-remover"

  function_name     = "exif-removal-${var.environment}"
  environment       = var.environment
  lambda_source_dir = "${path.root}/../../../lambda/exif_remover"

  # Use outputs from storage component
  source_bucket_name      = data.terraform_remote_state.storage.outputs.bucket_a_id
  source_bucket_arn       = data.terraform_remote_state.storage.outputs.bucket_a_arn
  destination_bucket_name = data.terraform_remote_state.storage.outputs.bucket_b_id
  destination_bucket_arn  = data.terraform_remote_state.storage.outputs.bucket_b_arn

  timeout     = 60
  memory_size = 512

  log_retention_days = 7

  environment_variables = {
    LOG_LEVEL = "INFO"
  }
}
