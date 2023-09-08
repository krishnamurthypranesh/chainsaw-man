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


# s3 bucket
resource "aws_s3_bucket" "painted_porch_deployment" {
  bucket = "painted-porch-deployment"
  acl = "private"
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

resource "aws_lambda_function" "painted_porch_backend" {
  function_name = "painted_porch_backend"
  role          = aws_iam_role.iam_for_lambda.arn

  s3_bucket = aws_s3_bucket.painted_porch_deployment.bucket
  s3_key = "painted_porch_payload.zip"

  package_type = "Zip"

  handler = "app.main.handler"
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
    destination_arn = aws_cloudwatch_log_group.painted_porch_api_gw.arn

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
    name = "journal_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "N"
  }

  tags = {
    Name        = "painted_porch_db"
    Environment = "prod"
  }
}

# create the codepipeline: source (github), codebuild, codedeploy
data "aws_iam_policy_document" "painted_porch_codedeploy_service_role_doc" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

  }
}

resource "aws_iam_role" "painted_porch_codedeploy_service_role" {
  name = "painted_porch_codedeploy_service_role"

  assume_role_policy = data.aws_iam_policy_document.painted_porch_codedeploy_service_role_doc.json
}

resource "aws_iam_role_policy_attachment" "painted_porch_codedeploy_service_role_atch" {
  role = aws_iam_role.painted_porch_codedeploy_service_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda"
}

resource "aws_codedeploy_app" "painted_porch_lambda_deploy_app" {
  compute_platform = "Lambda"
  name = "painted-porch-lambda-deploy"
}

resource "aws_codedeploy_deployment_config" "painted_porch_lambda_deploy_config" {
  deployment_config_name = "painted_porch_lambda_deploy_config"
  compute_platform = "Lambda"

  traffic_routing_config {
    type = "AllAtOnce"
  }
}

resource "aws_codedeploy_deployment_group" "painted_porch_lambda_deploy_group" {
  app_name = aws_codedeploy_app.painted_porch_lambda_deploy_app.name
  deployment_group_name = "painted_porch_lambda_deploy_group"
  service_role_arn = aws_iam_role.painted_porch_codedeploy_service_role.arn

  deployment_config_name = aws_codedeploy_deployment_config.painted_porch_lambda_deploy_config.id

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_STOP_ON_ALARM"]
  }

  alarm_configuration {
    alarms = ["painted-porch-deploy-alarm"]
    enabled = true
  }
}

resource "aws_codestarconnections_host" "github_chainsawman_host" {
  name = "github_chainsawman"
  provider_type = "GitHub"
}

resource "aws_codestarconnections_connection" "github_chainsawman_connection" {
  name = "github_chainsawman_connection"
  host_arn = aws_codestarconnections_host.github_chainsawman_host.arn
}

data "aws_iam_policy_document" "painted_porch_depl_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "painted_porch_backend_depl_role" {
  name               = "painted_porch_backend_depl_role"
  assume_role_policy = data.aws_iam_policy_document.painted_porch_depl_assume_role.json
}

data "aws_iam_policy_document" "painted_porch_backend_depl_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.painted_porch_deployment.arn,
      "${aws_s3_bucket.painted_porch_deployment.arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github_chainsawman_connection.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "painted_porch_backend_depl_policy" {
  name   = "painted_porch_backend_depl_policy"
  role   = aws_iam_role.painted_porch_backend_depl_role.id
  policy = data.aws_iam_policy_document.painted_porch_backend_depl_policy.json
}

resource "aws_codepipeline" "painted_porch_backend" {
  name = "painted-porch-backend"
  role_arn = aws_iam_role.painted_porch_backend_depl_role.arn

  artifact_store {
    location = aws_s3_bucket.painted_porch_deployment.bucket
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeStarSourceConnection"
      version = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn = aws_codestarconnections_connection.github_chainsawman_connection.arn
        FullRepositoryId = "krishnamurthypranesh/chainsaw-man"
        BranchName = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts =  ["source_output"]
      output_artifacts = ["build_output"]
      version = "1"

      configuration =  {
        ProjectName = "painted-porch-backend"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      input_artifacts = ["build_output"]
      version = "1"

      configuration = {
        ApplicationName = aws_codedeploy_app.painted_porch_lambda_deploy_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.painted_porch_lambda_deploy_group.id
      }

      region = var.aws_region
    }
  }
}