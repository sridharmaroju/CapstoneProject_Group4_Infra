resource "aws_lambda_function" "topupcard_lambda" {
  # checkov:skip=CKV_AWS_117:Ensure that AWS Lambda function is configured inside a VPC - Not Compliant
  # checkov:skip=CKV_AWS_116:Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ) - Not Compliant
  # checkov:skip=CKV_AWS_50:X-Ray tracing is enabled for Lambda - Not Compliant
  # checkov:skip=CKV_AWS_173:Check encryption settings for Lambda environmental variable - Not Compliant
  # checkov:skip=CKV_AWS_115:Ensure that AWS Lambda function is configured for function-level concurrent execution limit - Not Compliant
  # checkov:skip=CKV_AWS_272:Ensure AWS Lambda function is configured to validate code-signing - Not Compliant
  function_name = "${var.name_prefix}-topup-card-api-${local.workspace_safe}"
  description   = "Lambda function to top up in dynamoDB for -${local.workspace_safe}"
  runtime       = "python3.12"
  handler       = "TopupCard.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  memory_size   = 256 # Increase memory (default is 128 MB)
  timeout       = 10  # Increase timeout in seconds (default is 3)

  filename = "${path.module}/Lambda/TopupCardCode.zip"

  environment {
    variables = {
      CARDS_TABLE = "${var.name_prefix}-${var.cards_table_name}-${local.workspace_safe}"
    }
  }

  # IMPORTANT: Ignore changes to code so CI/CD can overwrite
  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }
}

resource "aws_cloudwatch_log_group" "topupcard_lambda_log" {
  # checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS - Not Compliant
  # checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year - Not Compliant
  name              = "/aws/lambda/${aws_lambda_function.topupcard_lambda.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "apigw_invoke_topup_card" {
  statement_id  = "AllowAPIGatewayInvokeFor-${local.workspace_safe}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.topupcard_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/card/*/topup"
}