# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "/aws/lambda/${var.function_name}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# EventBridge rule to capture S3 events
resource "aws_cloudwatch_event_rule" "s3_upload" {
  name        = "${var.function_name}-s3-event"
  description = "Capture S3 upload events for ${var.source_bucket_name}"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [var.source_bucket_name]
      }
      object = {
        key = [
          {
            suffix = ".jpg"
          },
          {
            suffix = ".JPG"
          },
          {
            suffix = ".jpeg"
          },
          {
            suffix = ".JPEG"
          }
        ]
      }
    }
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.function_name}-s3-event"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# EventBridge target (Lambda)
resource "aws_cloudwatch_event_target" "lambda" {
  rule       = aws_cloudwatch_event_rule.s3_upload.name
  target_id  = "lambda"
  arn        = aws_lambda_function.this.arn
  depends_on = [aws_cloudwatch_event_rule.s3_upload, aws_lambda_function.this]
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_upload.arn
  depends_on    = [aws_cloudwatch_event_rule.s3_upload, aws_lambda_function.this]
}
