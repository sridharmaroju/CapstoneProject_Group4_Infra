resource "aws_secretsmanager_secret" "mysql" {
  # checkov:skip=CKV_AWS_149: "Ensure that Secrets Manager secret is encrypted using KMS CMK"
  # checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled"
  name                    = "${var.name_prefix}-${local.workspace_safe}/rds/mysql/admin"
  description             = "RDS MySQL admin credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.mysql.result
  })
}


resource "aws_secretsmanager_secret" "mysql_connection_info" {
  # checkov:skip=CKV_AWS_149: "Ensure that Secrets Manager secret is encrypted using KMS CMK"
  # checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled"
  name                    = "${var.name_prefix}-${local.workspace_safe}/rds/mysql/connection"
  description             = "RDS MySQL connection info"
  recovery_window_in_days = 0
}


resource "aws_secretsmanager_secret_version" "mysql_connection_info" {
  depends_on = [aws_db_instance.mysql] # ensures DB exists first
  secret_id  = aws_secretsmanager_secret.mysql_connection_info.id

  secret_string = jsonencode({
    host     = aws_db_instance.mysql.address
    database = aws_db_instance.mysql.db_name
    port     = aws_db_instance.mysql.port
  })
}