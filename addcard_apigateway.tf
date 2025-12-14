

# API Resource for /card
resource "aws_api_gateway_resource" "card" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "card"
}

# API Resource for /card/{cardId}/add
resource "aws_api_gateway_resource" "add" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.card.id
  path_part   = "add"
}

# # POST method
resource "aws_api_gateway_method" "add_post" {
  # checkov:skip=CKV_AWS_59:Ensure there is no open access to back-end resources through API - Not Compliant
  # checkov:skip=CKV2_AWS_53:Ensure AWS API gateway request is validated - Not Compliant
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.add.id
  http_method   = "POST"
  authorization = "NONE"
  #   authorization = "COGNITO_USER_POOLS"
  #   authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "add_card_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.add.id
  http_method = aws_api_gateway_method.add_post.http_method

  type                    = "AWS"
  integration_http_method = "POST"

  uri = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.addcard_queue.name}"

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

resource "aws_api_gateway_integration_response" "add_card_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.add.id
  http_method = aws_api_gateway_method.add_post.http_method

  # 1. The HTTP status code the client should receive (200 OK)
  status_code = aws_api_gateway_method_response.add_post_response_200.status_code

  # 2. The Integration Status Code (from SQS) we are mapping (200 OK)
  selection_pattern = "" # Maps to all 200 responses if left blank

  # 3. Mapping Templates to format the SQS response body
  response_templates = {
    "application/json" = <<-EOF
                            {
                                "status": "success",
                                "message": "Add Card request successfully queued.",
                                "sqs_message_id": "$input.json('$.SendMessageResponse.SendMessageResult.MessageId')"
                            }
                            EOF
  }

  #   # NOTE: You may also need to define the method response if you haven't already:
  #   depends_on = [
  #     aws_api_gateway_method_response.add_post_response_200
  #   ]
}

# Ensure you have this corresponding method response resource defined
resource "aws_api_gateway_method_response" "add_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.add.id
  http_method = aws_api_gateway_method.add_post.http_method
  status_code = "200"
}
