resource "aws_api_gateway_rest_api" "api" {
  # checkov:skip=CKV_AWS_237:Ensure Create before destroy for API Gateway - Not Compliant
  name        = "${var.name_prefix}-api-${local.workspace_safe}"
  description = "API for Capstone Project"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api" {
  # checkov:skip=CKV_AWS_217: Ensure Create before destroy for API deployments - Not Compliant
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on = [
    aws_api_gateway_method.add_post,
    aws_api_gateway_integration.add_card_integration,
    aws_api_gateway_method.getTransactionHistory_post,
    aws_api_gateway_integration.getTransactionHistory_integration,
    aws_api_gateway_method.getCards_post,
    aws_api_gateway_integration.getCards_integration,
    aws_api_gateway_method.topup_post,
    aws_api_gateway_integration.topup_integration,
    aws_api_gateway_method.deduct_post,
    aws_api_gateway_integration.deduct_integration
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.add_post.id,
      aws_api_gateway_integration.add_card_integration.id,
      aws_api_gateway_method.getTransactionHistory_post.id,
      aws_api_gateway_integration.getTransactionHistory_integration.id,
      aws_api_gateway_method.getCards_post.id,
      aws_api_gateway_integration.getCards_integration.id,
      aws_api_gateway_method.topup_post.id,
      aws_api_gateway_integration.topup_integration.id,
      aws_api_gateway_method.deduct_post.id,
      aws_api_gateway_integration.deduct_integration.id
    ]))
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  # checkov:skip=CKV_AWS_76:Ensure API Gateway has Access Logging enabled - Not Compliant
  # checkov:skip=CKV_AWS_120:Ensure API Gateway caching is enabled - Not Compliant
  # checkov:skip=CKV_AWS_73:Ensure API Gateway has X-Ray Tracing enabled - Not Compliant
  # checkov:skip=CKV2_AWS_51:Ensure AWS API Gateway endpoints uses client certificate authentication - Not Compliant
  # checkov:skip=CKV2_AWS_4:Ensure API Gateway stage have logging level defined as appropriate - Not Compliant
  # checkov:skip=CKV2_AWS_29:Ensure public API gateway are protected by WAF - Not Compliant
  # checkov:skip=CKV2_AWS_77: "Ensure AWS API Gateway Rest API attached WAFv2 WebACL is configured with AMR for Log4j Vulnerability"
  # Use the current workspace name for the stage name
  stage_name = local.workspace_safe

  # The count argument is the key:
  # It creates this resource ONLY if the current workspace is 'dev' or 'prod'.
  # If you create another workspace like 'qa', it won't deploy a stage, 
  # but you can add it to the list here if needed.
  count = (contains(["dev", "prod"], local.workspace_safe) || startswith(local.workspace_safe, "sandbox-")) ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api.id
}

resource "aws_api_gateway_domain_name" "custom" {
  # checkov:skip=CKV_AWS_206:Ensure API Gateway Domain uses a modern security Policy - Not Compliant
  domain_name              = "api.${var.name_prefix}.${local.workspace_safe}.${var.domain}"
  regional_certificate_arn = module.acm.acm_certificate_arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  depends_on  = [data.aws_api_gateway_domain_name.custom_ready]
  count       = (contains(["dev", "prod"], local.workspace_safe) || startswith(local.workspace_safe, "sandbox-")) ? 1 : 0
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api_stage[0].stage_name
  domain_name = aws_api_gateway_domain_name.custom.domain_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  authorizer_uri         = "" # Not needed for Cognito, see next
  authorizer_credentials = null
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [aws_cognito_user_pool.user_pool.arn]
  identity_source        = "method.request.header.Authorization"
}