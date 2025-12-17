resource "aws_s3_bucket" "static_bucket" {
  # checkov:skip=CKV_AWS_145:Ensure that S3 buckets are encrypted with KMS by default - Not Compliant
  # checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled - Not Compliant
  # checkov:skip=CKV2_AWS_62:Ensure S3 buckets should have event notifications enabled - Not Compliant
  # checkov:skip=CKV2_AWS_6:Ensure that S3 bucket has a Public Access block - Not Compliant
  # checkov:skip=CKV2_AWS_61:Ensure that an S3 bucket has a lifecycle configuration - Not Compliant
  # checkov:skip=CKV_AWS_21:Ensure all data stored in the S3 bucket have versioning enabled - Not Compliant
  # checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled - Not Compliant
  bucket        = "${var.name_prefix}-${var.bucket_name}-${local.workspace_safe}"
  force_destroy = true
  tags = {
    Name = "${var.name_prefix}-${var.bucket_name}-${local.workspace_safe}"
  }
}