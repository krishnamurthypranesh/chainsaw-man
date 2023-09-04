# create vpc
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id

    cidr_block = "10.0.0.0/24"

    tags = {
        Vpc = "main"
    }
}


# create lambda and associated resources: ecr
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "painted_porch_backend" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  s3_bucket = aws_s3.lambda_deployment_bucket.name
  function_name = "painted_porch_backend"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "app.main.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  environment {
    variables = {
        Environment = "prod"
    }
  }
}

# create api gateway with execution id set to true
resource "aws_apigatewayv2_api" "painted_porch" {
  name          = "painted_porch_api_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "painted_porch" {
  api_id = aws_apigatewayv2_api.painted_porch.id

  name        = "painted_porch_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "painted_porch" {
  api_id = aws_apigatewayv2_api.painted_porch.id

  integration_uri    = aws_lambda_function.painted_porch_backend.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "painted_porch" {
  api_id = aws_apigatewayv2_api.painted_porch.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.painted_porch.id}"
}

resource "aws_cloudwatch_log_group" "painted_porch_api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.painted_porch.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "painted_porch_api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.painted_porch_backend.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.painted_porch.execution_arn}/*/*"
}

# create dynamodb
resource "aws_dynamodb_table" "painted_porch_entries" {
  name           = "PaintedPorchEntries"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "journal_id"
  range_key      = "created_at"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "content"
    type = "M"
  }

  attribute {
    name = "word_count"
    type = "N"
  }

  tags = {
    Name        = "painted_porch_db"
    Environment = "prod"
  }
}

# create the codepipeline: source (github), codebuild, codedeploy
