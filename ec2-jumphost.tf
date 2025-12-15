resource "aws_security_group" "ec2_jumphost_sg" {
  # checkov:skip=CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22"
  # checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  # checkov:skip=CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
  name        = "${var.name_prefix}-${local.workspace_safe}-ec2-jumphost-public-sg"
  description = "Allow SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # restrict in real use
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_jumphost" {
  # checkov:skip=CKV_AWS_88: "EC2 instance should not have public IP."
  # checkov:skip=CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
  # checkov:skip=CKV_AWS_135: "Ensure that EC2 is EBS optimized"
  # checkov:skip=CKV_AWS_126: "Ensure that detailed monitoring is enabled for EC2 instances"
  # checkov:skip=CKV_AWS_8: "Ensure all data stored in the Launch configuration or instance Elastic Blocks Store is securely encrypted"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ec2_jumphost_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_jumphost_profile.name
  user_data = templatefile("${path.module}/EC2-Jumphost_UserData/launch.sh", {
    account_secret_arn = aws_secretsmanager_secret.mysql.arn
    db_secret_arn      = aws_secretsmanager_secret.mysql_connection_info.arn
  })

  depends_on = [
    aws_secretsmanager_secret.mysql,
    aws_secretsmanager_secret.mysql_connection_info,
    aws_db_instance.mysql
  ]

  tags = {
    Name = "${var.name_prefix}-${local.workspace_safe}-ec2-jumphost"
  }
}