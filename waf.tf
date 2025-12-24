resource "aws_wafv2_web_acl" "waf" {
  # checkov:skip=CKV_AWS_192: "Ensure WAF prevents message lookup in Log4j2. See CVE-2021-44228 aka log4jshell"
  # checkov:skip=CKV2_AWS_31: "Ensure WAF2 has a Logging Configuration"
  name  = "${var.name_prefix}-api-waf-${local.workspace_safe}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  ############################
  # 1. AWS Managed Common Rules
  ############################
  rule {
    name     = "AWSCommonRules"
    priority = 1

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