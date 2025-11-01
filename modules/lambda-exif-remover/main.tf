terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Lambda function
# Note: The Lambda deployment package should be pre-built using the build.sh script
# in the lambda source directory to include all dependencies
resource "aws_lambda_function" "this" {
  filename         = "${var.lambda_source_dir}/lambda_function.zip"
  function_name    = var.function_name
  role             = aws_iam_role.lambda.arn
  handler          = var.handler
  source_code_hash = filebase64sha256("${var.lambda_source_dir}/lambda_function.zip")
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = merge(
      var.environment_variables,
      {
        DESTINATION_BUCKET = var.destination_bucket_name
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name        = var.function_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

