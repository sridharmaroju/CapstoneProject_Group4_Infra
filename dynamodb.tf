resource "aws_dynamodb_table" "cards" {
  # checkov:skip=CKV_AWS_28:Ensure DynamoDB point in time recovery (backup) is enabled - Not Compliant
  # checkov:skip=CKV_AWS_119:Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK - Not Compliant
  name         = "${var.name_prefix}-${var.cards_table_name}-${local.workspace_safe}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "CARD_NUMBER"

  attribute {
    name = "CARD_NUMBER"
    type = "S"
  }
}