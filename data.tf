# data "aws_iam_policy_document" "allow_access_from_cloudfront" {
#   statement {

#     actions = [
#       "s3:GetObject",
#     ]

#     resources = [
#       aws_s3_bucket.static_bucket.arn,
#       "${aws_s3_bucket.static_bucket.arn}/*",
#     ]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceArn"
#       values   = [aws_cloudfront_distribution.s3_distribution.arn]
#     }
#   }
# }

# data "aws_route53_zone" "zone" {
#   name = var.domain
# }

# data "aws_api_gateway_domain_name" "custom_ready" {
#   depends_on  = [aws_api_gateway_domain_name.custom]
#   domain_name = aws_api_gateway_domain_name.custom.domain_name
# }

data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  id = module.vpc.vpc_id
}