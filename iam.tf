resource "aws_iam_role" "lambda_exec" {
  name = "${var.name_prefix}-lambda-exe-role-${local.workspace_safe}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_role" {
  # checkov:skip=CKV_AWS_355:Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions - Not Compliant
  # checkov:skip=CKV_AWS_290:Ensure IAM policies does not allow write access without constraints - Not Compliant
  name = "${var.name_prefix}-lamda-api-ddbaccess-${local.workspace_safe}"

  policy = <<POLICY
 {
     "Version": "2012-10-17",
     "Statement": [
         {
             "Effect": "Allow",
             "Action": [
                 "secretsmanager:GetSecretValue",
                 "sqs:ReceiveMessage",
                 "sqs:DeleteMessage",
                 "sqs:GetQueueAttributes",
                 "sqs:ChangeMessageVisibility"
             ],
             "Resource": [
                  "${aws_secretsmanager_secret.mysql_connection_info.arn}",
                  "${aws_secretsmanager_secret.mysql.arn}",
                  "${aws_sqs_queue.addcard_queue.arn}",
                  "${aws_sqs_queue.topup_queue.arn}",
                  "${aws_sqs_queue.deduct_queue.arn}"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "logs:CreateLogGroup",
                 "logs:CreateLogStream",
                 "logs:PutLogEvents"
             ],
             "Resource": "*"
         }
     ]
 }
 POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_role.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role" "apigw_sqs_role" {
  name = "${var.name_prefix}-apigw-sqs-role-${local.workspace_safe}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "apigw_sqs_policy" {
  role = aws_iam_role.apigw_sqs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sqs:SendMessage"
      Resource = [
        aws_sqs_queue.addcard_queue.arn,
        aws_sqs_queue.topup_queue.arn,
        aws_sqs_queue.deduct_queue.arn
      ]
    }]
  })
}

resource "aws_iam_policy" "ec2_secrets_access" {
  name = "${var.name_prefix}-ec2-secretsmanager-access-${local.workspace_safe}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = [
        aws_secretsmanager_secret.mysql_connection_info.arn,
        aws_secretsmanager_secret.mysql.arn
      ]
    }]
  })
}

resource "aws_iam_role" "ec2_jumphost_role" {
  name = "${var.name_prefix}-${local.workspace_safe}-ec2-db-init-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets" {
  role       = aws_iam_role.ec2_jumphost_role.name
  policy_arn = aws_iam_policy.ec2_secrets_access.arn
}

resource "aws_iam_instance_profile" "ec2_jumphost_profile" {
  name = "${var.name_prefix}-${local.workspace_safe}-ec2-db-init-profile"
  role = aws_iam_role.ec2_jumphost_role.name
}