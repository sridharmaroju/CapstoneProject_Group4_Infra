

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.addcard_lambda_sg.id, aws_security_group.getCards_lambda_sg.id, aws_security_group.getTransactionHistory_lambda_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.secrets_endpoint_sg.id]
  private_dns_enabled = true
}

# Security group for the Secrets Manager endpoint
resource "aws_security_group" "secrets_endpoint_sg" {
  name        = "${var.name_prefix}-secrets-endpoint-sg-${local.workspace_safe}"
  description = "SG for Secrets Manager VPC endpoint"
  vpc_id      = module.vpc.vpc_id
}

# Ingress rule to allow Lambda SG to connect
resource "aws_security_group_rule" "ingress_addcard_lambda_to_sm_endpoint" {
  # checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.secrets_endpoint_sg.id
  source_security_group_id = aws_security_group.addcard_lambda_sg.id
}

# Ingress rule to allow Lambda SG to connect
resource "aws_security_group_rule" "ingress_getcards_lambda_to_sm_endpoint" {
  # checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.secrets_endpoint_sg.id
  source_security_group_id = aws_security_group.getCards_lambda_sg.id
}

# Ingress rule to allow Lambda SG to connect
resource "aws_security_group_rule" "ingress_gettransactionhistory_lambda_to_sm_endpoint" {
  # checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.secrets_endpoint_sg.id
  source_security_group_id = aws_security_group.getTransactionHistory_lambda_sg.id
}

# Ingress rule to allow EC2 Jumphost SG to connect
resource "aws_security_group_rule" "ingress_ec2_jumphost_to_sm_endpoint" {
  # checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.secrets_endpoint_sg.id
  source_security_group_id = aws_security_group.ec2_jumphost_sg.id
}

# Ingress rule to allow Lambda SG to connect
resource "aws_security_group_rule" "ingress_topup_lambda_to_sm_endpoint" {
  # checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.secrets_endpoint_sg.id
  source_security_group_id = aws_security_group.topup_lambda_sg.id
}

# Ingress rule to allow Lambda SG to connect
resource "aws_security_group_rule" "ingress_deduct_lambda_to_sm_endpoint" {
  # checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.secrets_endpoint_sg.id
  source_security_group_id = aws_security_group.deduct_lambda_sg.id
}