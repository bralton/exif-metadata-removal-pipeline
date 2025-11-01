variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
}

variable "user_a_name" {
  description = "Name for User A (read/write access to Bucket A)"
  type        = string
}

variable "user_b_name" {
  description = "Name for User B (read-only access to Bucket B)"
  type        = string
}

variable "bucket_a_name" {
  description = "Name of Bucket A (for tagging purposes)"
  type        = string
}

variable "bucket_a_arn" {
  description = "ARN of Bucket A"
  type        = string
}

variable "bucket_b_name" {
  description = "Name of Bucket B (for tagging purposes)"
  type        = string
}

variable "bucket_b_arn" {
  description = "ARN of Bucket B"
  type        = string
}


variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
