resource "aws_cloudfront_origin_access_control" "oac-s3" {
  name                              = "${aws_s3_bucket.static_bucket.id}-oac"
  description                       = "Allow Cloudfront to access S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  # checkov:skip=CKV_AWS_374:Ensure AWS CloudFront web distribution has geo restriction enabled - Not Compliant
  # checkov:skip=CKV_AWS_86:Ensure CloudFront distribution has Access Logging enabled - Not Compliant
  # checkov:skip=CKV_AWS_34:Ensure CloudFront distribution ViewerProtocolPolicy is set to HTTPS - Not Compliant
  # checkov:skip=CKV_AWS_174:Verify CloudFront Distribution Viewer Certificate is using TLS v1.2 or higher - Not Compliant
  # checkov:skip=CKV_AWS_310:Ensure CloudFront distributions should have origin failover configured - Not Compliant
  # checkov:skip=CKV_AWS_68:CloudFront Distribution should have WAF enabled - Not Compliant
  # checkov:skip=CKV2_AWS_47:Ensure AWS CloudFront attached WAFv2 WebACL is configured with AMR for Log4j Vulnerability - Not Compliant
  # checkov:skip=CKV2_AWS_32:Ensure CloudFront distribution has a response headers policy attached - Not Compliant
  origin {
    domain_name              = aws_s3_bucket.static_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac-s3.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = ""
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  aliases = [local.alternate_domain_name, local.www_domain_name]
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}