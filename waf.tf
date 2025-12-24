resource "aws_wafv2_web_acl" "waf" {
  # checkov:skip=CKV_AWS_192: "Ensure WAF prevents message lookup in Log4j2. See CVE-2021-44228 aka log4jshell"
  # checkov:skip=CKV2_AWS_31: "Ensure WAF2 has a Logging Configuration"
  name  = "${var.name_prefix}-api-waf-${local.workspace_safe}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  ############################
  # 1. Allow ONLY custom domain
  ############################
  rule {
    name     = "AllowCustomDomainOnly"
    priority = 0

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        search_string = "api.example.com"
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "EXACTLY"

        text_transformation {
          priority = 0
          type     = "LOWERCASE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allowCustomDomain"
      sampled_requests_enabled   = true
    }
  }

  ############################
  # 2. Block everything else (Host-based)
  ############################
  rule {
    name     = "BlockNonCustomDomain"
    priority = 1

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          byte_match_statement {
            search_string = "api.example.com"
            field_to_match {
              single_header {
                name = "host"
              }
            }
            positional_constraint = "EXACTLY"

            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blockNonCustomDomain"
      sampled_requests_enabled   = true
    }
  }

  ############################
  # 3. Rate limiting (per IP)
  ############################
  rule {
    name     = "RateLimitPerIP"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimit"
      sampled_requests_enabled   = true
    }
  }

  ############################
  # 4. AWS Managed Common Rules
  ############################
  rule {
    name     = "AWSCommonRules"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "commonRules"
      sampled_requests_enabled   = true
    }
  }

  ############################
  # Web ACL visibility
  ############################
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "commonRuleApiWaf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "apiwaf" {
  resource_arn = "arn:aws:apigateway:${var.region}::/restapis/${aws_api_gateway_rest_api.api.id}/stages/${aws_api_gateway_stage.api_stage[0].stage_name}"
  web_acl_arn  = aws_wafv2_web_acl.waf.arn

  depends_on = [
    aws_api_gateway_stage.api_stage,
    aws_api_gateway_deployment.api
  ]
}