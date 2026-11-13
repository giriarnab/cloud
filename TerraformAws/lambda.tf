data "archive_file" "lambda_greeter" {
  type = "zip"

  source_dir  = "${path.module}/orchestrator/service"
  output_path = "${path.module}/orchestrator/service/greeter.zip"
}

resource "aws_lambda_function" "greeter" {
  function_name = "Greeter"

  runtime = "nodejs20.x"
  handler = "greeter.handler"
  filename = data.archive_file.lambda_greeter.output_path
  source_code_hash = data.archive_file.lambda_greeter.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "greeter" {
  name = "/aws/lambda/${aws_lambda_function.greeter.function_name}"

  retention_in_days = 30
}


