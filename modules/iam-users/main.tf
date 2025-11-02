terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# User A - Read/Write access to Bucket A
resource "aws_iam_user" "user_a" {
  name = var.user_a_name

  tags = merge(
    var.tags,
    {
      Name        = var.user_a_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "Read/Write access to ${var.bucket_a_name}"
    }
  )
}

resource "aws_iam_access_key" "user_a" {
  user = aws_iam_user.user_a.name
}

resource "aws_iam_user_policy" "user_a" {
  name = "${var.user_a_name}-bucket-a-policy"
  user = aws_iam_user.user_a.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = var.bucket_a_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "${var.bucket_a_arn}/*"
      }
    ]
  })
}

# User B - Read-only access to Bucket B
resource "aws_iam_user" "user_b" {
  name = var.user_b_name

  tags = merge(
    var.tags,
    {
      Name        = var.user_b_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "Read-only access to ${var.bucket_b_name}"
    }
  )
}

resource "aws_iam_access_key" "user_b" {
  user = aws_iam_user.user_b.name
}

resource "aws_iam_user_policy" "user_b" {
  name = "${var.user_b_name}-bucket-b-policy"
  user = aws_iam_user.user_b.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = var.bucket_b_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${var.bucket_b_arn}/*"
      }
    ]
  })
}

# Store secrets in AWS Secrets Manager (recommended for production)
resource "aws_secretsmanager_secret" "user_a_credentials" {
  name        = "${var.environment}/${var.user_a_name}/credentials"
  description = "Access credentials for ${var.user_a_name}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.user_a_name}-credentials"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_secretsmanager_secret_version" "user_a_credentials" {
  secret_id = aws_secretsmanager_secret.user_a_credentials.id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.user_a.id
    secret_access_key = aws_iam_access_key.user_a.secret
  })
}

resource "aws_secretsmanager_secret" "user_b_credentials" {
  name        = "${var.environment}/${var.user_b_name}/credentials"
  description = "Access credentials for ${var.user_b_name}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.user_b_name}-credentials"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_secretsmanager_secret_version" "user_b_credentials" {
  secret_id = aws_secretsmanager_secret.user_b_credentials.id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.user_b.id
    secret_access_key = aws_iam_access_key.user_b.secret
  })
}
