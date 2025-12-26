resource "aws_iam_role" "cognito_lambda_role" {
  name = "${var.name_prefix}-cognito-lambda-role-${local.workspace_safe}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cognito_lambda_policy" {
  # checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "***" as a statement's resource for restrictable actions"
  # checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  role = aws_iam_role.cognito_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:Subscribe"
        Resource = aws_sns_topic.system_notifications.arn
      }
    ]
  })
}

resource "aws_lambda_function" "post_confirmation" {
  # checkov:skip=CKV_AWS_117:Ensure that AWS Lambda function is configured inside a VPC - Not Compliant
  # checkov:skip=CKV_AWS_116:Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ) - Not Compliant
  # checkov:skip=CKV_AWS_50:X-Ray tracing is enabled for Lambda - Not Compliant
  # checkov:skip=CKV_AWS_173:Check encryption settings for Lambda environmental variable - Not Compliant
  # checkov:skip=CKV_AWS_115:Ensure that AWS Lambda function is configured for function-level concurrent execution limit - Not Compliant
  # checkov:skip=CKV_AWS_272:Ensure AWS Lambda function is configured to validate code-signing - Not Compliant
  function_name = "${var.name_prefix}-cognito-sns-${local.workspace_safe}"
  description   = "Lambda function to add verifired user into SNS for -${local.workspace_safe}"
  role          = aws_iam_role.cognito_lambda_role.arn
  handler       = "PostConfirmationSNS.handler"
  runtime       = "python3.12"
  timeout       = 10

  filename = "${path.module}/Lambda/PostConfirmationSNS.zip"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.system_notifications.arn
    }
  }
}

resource "aws_cloudwatch_log_group" "cognito_lambda_log" {
  # checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS - Not Compliant
  # checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year - Not Compliant
  name              = "/aws/lambda/${aws_lambda_function.post_confirmation.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "allow_cognito_lambda" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_confirmation.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn

  depends_on = [
    aws_lambda_function.post_confirmation
  ]
}


