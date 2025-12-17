module "acm" {
  # checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash - Not Compliant
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = local.alternate_domain_name
  zone_id     = data.aws_route53_zone.zone.id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${local.alternate_domain_name}",
  "www.${var.name_prefix}.${local.workspace_safe}.${var.domain}"]

  wait_for_validation = true

  tags = {
    Name = local.alternate_domain_name
  }
}