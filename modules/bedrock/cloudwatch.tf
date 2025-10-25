resource "aws_cloudwatch_log_delivery_source" "kb_logs" {
  count        = 1
  name         = "bedrock_knowledgebase"
  log_type     = "APPLICATION_LOGS"
  resource_arn = "${aws_bedrockagent_knowledge_base.bedrock_knowledgebase.arn}"
}

resource "aws_cloudwatch_log_group" "kb_logs" {
  count = 1
  name  = "/aws/bedrock/knowledge-base/APPLICATION_LOGS/bedrock_knowledgebase"
}

resource "aws_cloudwatch_log_resource_policy" "kb_logs" {
  count       = 1
  policy_name = "bedrock_knowledgebase_logs"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite20150319"
        Effect = "Allow"
        Principal = {
          Service = ["delivery.logs.amazonaws.com"]
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["${aws_cloudwatch_log_group.kb_logs[0].arn}:log-stream:*"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = ["${var.awsAccountId}"]
          },
          ArnLike = {
            "aws:SourceArn" = ["arn:aws:bedrock:${var.awsRegion}:${var.awsAccountId}:*"]
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_delivery_destination" "kb_logs_cloudwatch_logs" {
  count = 1
  name  = "bedrock_knowledgebase-cloudwatch-logs"
  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.kb_logs[0].arn
  }
  depends_on = [aws_cloudwatch_log_resource_policy.kb_logs]
}

resource "aws_cloudwatch_log_delivery" "kb_logs_cloudwatch_logs" {
  count                    = 1
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.kb_logs_cloudwatch_logs[0].arn
  delivery_source_name     = aws_cloudwatch_log_delivery_source.kb_logs[0].name
}