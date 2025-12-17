locals {
  # sanitize workspace name: convert to lowercase
  workspace_safe        = lower(terraform.workspace)
  alternate_domain_name = "${var.name_prefix}.${local.workspace_safe}.${var.domain}"
  www_domain_name       = "www.${var.name_prefix}.${local.workspace_safe}.${var.domain}"
  s3_origin_id          = "${aws_s3_bucket.static_bucket.bucket}-Origin"
}