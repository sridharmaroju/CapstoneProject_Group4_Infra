# Standard SQS Queue
resource "aws_sqs_queue" "topup_queue" {
  # checkov:skip=CKV_AWS_27: "Ensure all data stored in the SQS queue is encrypted"
  name                       = "${var.name_prefix}-topup-queue-${local.workspace_safe}"
  delay_seconds              = 0
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds  = 0
  fifo_queue                 = false
  tags = {
    Name = "${var.name_prefix}-topup-queue-${local.workspace_safe}"
  }
}

# Optional: Grant Lambda permission to read from the queue
resource "aws_lambda_event_source_mapping" "topup_lambda_sqs" {
  event_source_arn = aws_sqs_queue.topup_queue.arn
  function_name    = aws_lambda_function.topup_lambda.arn
  batch_size       = 10
  enabled          = true
}
