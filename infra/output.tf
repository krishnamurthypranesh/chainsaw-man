output "painted_porch_base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.painted_porch.invoke_url
}