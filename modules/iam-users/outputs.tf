output "user_a_name" {
  description = "Name of User A"
  value       = aws_iam_user.user_a.name
}

output "user_b_name" {
  description = "Name of User B"
  value       = aws_iam_user.user_b.name
}

output "user_a_secrets_manager_arn" {
  description = "ARN of Secrets Manager secret for User A credentials"
  value       = aws_secretsmanager_secret.user_a_credentials[0].arn
}

output "user_b_secrets_manager_arn" {
  description = "ARN of Secrets Manager secret for User B credentials"
  value       = aws_secretsmanager_secret.user_b_credentials[0].arn
}
