resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.alternate_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.www_domain_name
  type    = "CNAME"
  ttl     = 300
  records = [local.alternate_domain_name]
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "api.${var.name_prefix}.${local.workspace_safe}.${var.domain}"
  type    = "CNAME"
  ttl     = 300

  records = [
    aws_api_gateway_domain_name.custom.regional_domain_name
  ]
}