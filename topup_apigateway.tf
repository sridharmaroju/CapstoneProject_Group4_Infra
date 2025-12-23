# API Resource for /card/topup
resource "aws_api_gateway_resource" "topup" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.card.id
  path_part   = "topup"
}

# # POST method
resource "aws_api_gateway_method" "topup_post" {
  # checkov:skip=CKV_AWS_59:Ensure there is no open access to back-end resources through API - Not Compliant
  # checkov:skip=CKV2_AWS_53:Ensure AWS API gateway request is validated - Not Compliant
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.topup.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

# Integration with Lambda
resource "aws_api_gateway_integration" "topup_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.topup.id
  http_method             = aws_api_gateway_method.topup_post.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"

  uri = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.topup_queue.name}"

  credentials = aws_iam_role.apigw_sqs_role.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = <<EOF
Action=SendMessage&MessageBody=$util.urlEncode($input.body)
EOF
  }
}

# Ensure you have this corresponding method response resource defined
resource "aws_api_gateway_method_response" "topup_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.topup.id
  http_method = aws_api_gateway_method.topup_post.http_method
  status_code = "200"

  # CORS START: enable headers in method response
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
  # CORS END
}

resource "aws_api_gateway_integration_response" "topup_card_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.topup.id
  http_method = aws_api_gateway_method.topup_post.http_method

  # 1. The HTTP status code the client should receive (200 OK)
  status_code = aws_api_gateway_method_response.topup_post_response_200.status_code

  # 2. The Integration Status Code (from SQS) we are mapping (200 OK)
  selection_pattern = "" # Maps to all 200 responses if left blank

  # 3. Mapping Templates to format the SQS response body
  response_templates = {
    "application/json" = <<-EOF
                            {
                                "status": "success",
                                "message": "Topup request successfully queued.",
                                "sqs_message_id": $input.json('$.SendMessageResponse.SendMessageResult.MessageId')
                            }
                            EOF
  }

  # CORS START: add headers to POST integration response
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.allowed_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
  }
  # CORS END

  # NOTE: You may also need to define the method response if you haven't already:
  depends_on = [
    aws_api_gateway_method_response.topup_post_response_200,
    aws_api_gateway_integration.topup_integration
  ]
}

resource "aws_api_gateway_method" "topup_options" {
  # checkov:skip=CKV2_AWS_53: "Ensure AWS API gateway request is validated"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.topup.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "topup_options_mock" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.topup.id
  http_method = aws_api_gateway_method.topup_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "topup_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.topup.id
  http_method = aws_api_gateway_method.topup_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "topup_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.topup.id
  http_method = aws_api_gateway_method.topup_options.http_method
  status_code = aws_api_gateway_method_response.topup_options_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.allowed_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
  }

  response_templates = {
    "application/json" = ""
  }
}