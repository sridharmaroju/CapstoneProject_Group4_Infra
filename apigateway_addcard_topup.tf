# # API Resource for /card
# resource "aws_api_gateway_resource" "card" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = "card"
# }

# # API Resource for /card/{cardId}
# resource "aws_api_gateway_resource" "card_id" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_resource.card.id
#   path_part   = "{cardId}"
# }

# # API Resource for /card/{cardId}/topup
# resource "aws_api_gateway_resource" "topup" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_resource.card_id.id
#   path_part   = "topup"
# }

# # API Resource for /card/{cardId}/add
# resource "aws_api_gateway_resource" "add" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_resource.card_id.id
#   path_part   = "add"
# }

# # POST method
# resource "aws_api_gateway_method" "topup_post" {
#   # checkov:skip=CKV_AWS_59:Ensure there is no open access to back-end resources through API - Not Compliant
#   # checkov:skip=CKV2_AWS_53:Ensure AWS API gateway request is validated - Not Compliant
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.topup.id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# # POST method
# resource "aws_api_gateway_method" "add_post" {
#   # checkov:skip=CKV_AWS_59:Ensure there is no open access to back-end resources through API - Not Compliant
#   # checkov:skip=CKV2_AWS_53:Ensure AWS API gateway request is validated - Not Compliant
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.add.id
#   http_method   = "POST"
#   authorization = "COGNITO_USER_POOLS"
#   authorizer_id = aws_api_gateway_authorizer.cognito.id
# }

# # Integration with Lambda
# resource "aws_api_gateway_integration" "topup_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.topup.id
#   http_method             = aws_api_gateway_method.topup_post.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.topupcard_lambda.invoke_arn
# }

# # Integration with Lambda
# resource "aws_api_gateway_integration" "add_card_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.add.id
#   http_method             = aws_api_gateway_method.add_post.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.addcard_lambda.invoke_arn
# }

# # # Lambda permission
# # resource "aws_lambda_permission" "apigw_topup" {
# #   statement_id  = "AllowAPIGatewayInvokeTopup"
# #   action        = "lambda:InvokeFunction"
# #   function_name = aws_lambda_function.topupcard_lambda.function_name
# #   principal     = "apigateway.amazonaws.com"
# #   source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/card/*/topup"
# # }
