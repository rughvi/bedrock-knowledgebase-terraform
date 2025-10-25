data "archive_file" "python_lambda_package" {  
  type = "zip"  
  source_file = "${path.module}/../../code/lambda_function.py" 
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda_knowledgebase_sync_function" {
  function_name = "lambdaKnowledgeBaseSync"
  filename      = "lambda.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role          = var.lambda_execution_role_arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  timeout       = 10

  environment {
    variables = {
      DATASOURCEID = "${var.bedrock_knowledgebase_id}"
      KNOWLEDGEBASEID = "${var.bedrock_datasource_id}"
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_knowledgebase_sync_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bedrock_s3_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bedrock_s3_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_knowledgebase_sync_function.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}