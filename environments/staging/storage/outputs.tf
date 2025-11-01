output "bucket_a_id" {
  description = "ID of Bucket A"
  value       = module.bucket_a.bucket_id
}

output "bucket_a_arn" {
  description = "ARN of Bucket A"
  value       = module.bucket_a.bucket_arn
}

output "bucket_b_id" {
  description = "ID of Bucket B"
  value       = module.bucket_b.bucket_id
}

output "bucket_b_arn" {
  description = "ARN of Bucket B"
  value       = module.bucket_b.bucket_arn
}
