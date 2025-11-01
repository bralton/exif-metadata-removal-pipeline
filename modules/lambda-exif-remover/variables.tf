variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
}

variable "lambda_source_dir" {
  description = "Path to the Lambda function source code directory"
  type        = string
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}

variable "source_bucket_name" {
  description = "Name of the source S3 bucket (Bucket A)"
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN of the source S3 bucket (Bucket A)"
  type        = string
}

variable "destination_bucket_name" {
  description = "Name of the destination S3 bucket (Bucket B)"
  type        = string
}

variable "destination_bucket_arn" {
  description = "ARN of the destination S3 bucket (Bucket B)"
  type        = string
}

variable "environment_variables" {
  description = "Additional environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
