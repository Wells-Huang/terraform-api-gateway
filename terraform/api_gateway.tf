# ==========================================
# API Gateway REST API
# ==========================================

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-api"
  description = "API Gateway 作為 Load Balancer，路由到 Lambda 和 S3"

  binary_media_types = ["*/*"]

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "Main API Gateway"
  }
}

# ==========================================
# API 路徑 - /api
# ==========================================

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "todos"
}

resource "aws_api_gateway_resource" "todo_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.todos.id
  path_part   = "{id}"
}

# ==========================================
# Lambda Integration - GET /api/todos
# ==========================================

resource "aws_api_gateway_method" "todos_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "todos_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = aws_api_gateway_method.todos_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.todo_api.invoke_arn
}

# ==========================================
# Lambda Integration - POST /api/todos
# ==========================================

resource "aws_api_gateway_method" "todos_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "todos_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = aws_api_gateway_method.todos_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.todo_api.invoke_arn
}

# ==========================================
# Lambda Integration - DELETE /api/todos/{id}
# ==========================================

resource "aws_api_gateway_method" "todo_delete" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.todo_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "todo_delete" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.todo_id.id
  http_method             = aws_api_gateway_method.todo_delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.todo_api.invoke_arn
}

# ==========================================
# CORS - OPTIONS /api/todos
# ==========================================

resource "aws_api_gateway_method" "todos_options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "todos_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.todos_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "todos_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.todos_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "todos_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.todos_options.http_method
  status_code = aws_api_gateway_method_response.todos_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# ==========================================
# CORS - OPTIONS /api/todos/{id}
# ==========================================

resource "aws_api_gateway_method" "todo_options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.todo_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "todo_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.todo_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "todo_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.todo_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "todo_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.todo_options.http_method
  status_code = aws_api_gateway_method_response.todo_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# ==========================================
# S3 Website Proxy - /{proxy+}
# ==========================================

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}/{proxy}"
  integration_http_method = "ANY"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# ==========================================
# S3 Website Proxy - Root /
# ==========================================

resource "aws_api_gateway_method" "root" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_rest_api.main.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_rest_api.main.root_resource_id
  http_method             = aws_api_gateway_method.root.http_method
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}/index.html"
  integration_http_method = "GET"
}

# ==========================================
# API Gateway 部署
# ==========================================

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  depends_on = [
    aws_api_gateway_integration.todos_get,
    aws_api_gateway_integration.todos_post,
    aws_api_gateway_integration.todo_delete,
    aws_api_gateway_integration.proxy,
    aws_api_gateway_integration.root,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "prod"

  tags = {
    Name = "Production Stage"
  }
}

# ==========================================
# Lambda 權限 - 允許 API Gateway 調用
# ==========================================

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}
