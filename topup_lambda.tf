resource "aws_lambda_function" "topup_lambda" {
  # checkov:skip=CKV_AWS_117:Ensure that AWS Lambda function is configured inside a VPC - Not Compliant
  # checkov:skip=CKV_AWS_116:Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ) - Not Compliant
  # checkov:skip=CKV_AWS_50:X-Ray tracing is enabled for Lambda - Not Compliant
  # checkov:skip=CKV_AWS_173:Check encryption settings for Lambda environmental variable - Not Compliant
  # checkov:skip=CKV_AWS_115:Ensure that AWS Lambda function is configured for function-level concurrent execution limit - Not Compliant
  # checkov:skip=CKV_AWS_272:Ensure AWS Lambda function is configured to validate code-signing - Not Compliant
  function_name = "${var.name_prefix}-topup-api-${local.workspace_safe}"
  description   = "Lambda function to topup card in DB for -${local.workspace_safe}"
  runtime       = "python3.12"
  handler       = "Topup.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  memory_size   = 256 # Increase memory (default is 128 MB)
  timeout       = 30  # Increase timeout in seconds (default is 3)

  filename = "${path.module}/Lambda/TopupCode.zip"

  environment {
    variables = {
      DB_SECRET = aws_secretsmanager_secret.mysql.arn,
      DB_INFO   = aws_secretsmanager_secret.mysql_connection_info.arn
    }
  }

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.topup_lambda_sg.id]
  }

  # IMPORTANT: Ignore changes to code so CI/CD can overwrite
  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }

  depends_on = [aws_lambda_function.getTransactionHistory_lambda]
}

resource "aws_cloudwatch_log_group" "topup_lambda_log" {
  # checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS - Not Compliant
  # checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year - Not Compliant
  name              = "/aws/lambda/${aws_lambda_function.topup_lambda.function_name}"
  retention_in_days = 7
}

resource "aws_security_group" "topup_lambda_sg" {
  # checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  name        = "${var.name_prefix}-topup-lambda-sg-${local.workspace_safe}"
  description = "Security group for Topup Lambda function"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "l${var.name_prefix}-topup-lambda-sg-${local.workspace_safe}"
  }
}

resource "aws_security_group_rule" "egress_topup_lambda_to_sm_endpoint" {
  # checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.topup_lambda_sg.id
  cidr_blocks       = ["10.0.0.0/16"] # or the VPC CIDR
}