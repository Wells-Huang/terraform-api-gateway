# ==========================================
# Lambda 函數 - TODO API
# ==========================================

# 打包 Lambda 函數程式碼
data "archive_file" "lambda_todo" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/todo"
  output_path = "${path.module}/lambda-todo.zip"
}

resource "aws_lambda_function" "todo_api" {
  filename      = data.archive_file.lambda_todo.output_path
  function_name = "${var.project_name}-todo-api"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 256

  source_code_hash = data.archive_file.lambda_todo.output_base64sha256

  environment {
    variables = {
      TODO_BUCKET_NAME = aws_s3_bucket.todo_data.bucket
      TODO_OBJECT_KEY  = "todos.json"
    }
  }

  tags = {
    Name = "TODO API Lambda Function"
  }
}

# Lambda 日誌群組
resource "aws_cloudwatch_log_group" "lambda_todo" {
  name              = "/aws/lambda/${aws_lambda_function.todo_api.function_name}"
  retention_in_days = 7

  tags = {
    Name = "TODO Lambda Logs"
  }
}
