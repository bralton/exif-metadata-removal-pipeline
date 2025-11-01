# I dont like outputting unused variables as a rule
# But I can see an advantage to it here so the secret arns are known without looking them up
output "user_a_name" {
  description = "Name of User A (uploader)"
  value       = module.iam_users.user_a_name
}

output "user_b_name" {
  description = "Name of User B (reader)"
  value       = module.iam_users.user_b_name
}

output "user_a_secrets_manager_arn" {
  description = "ARN of Secrets Manager secret for User A credentials"
  value       = module.iam_users.user_a_secrets_manager_arn
}

output "user_b_secrets_manager_arn" {
  description = "ARN of Secrets Manager secret for User B credentials"
  value       = module.iam_users.user_b_secrets_manager_arn
}
