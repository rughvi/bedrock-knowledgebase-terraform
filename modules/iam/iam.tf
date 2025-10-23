resource "aws_iam_role" "bedrock" {
  name                = "bedrock-role"
  managed_policy_arns = [aws_iam_policy.bedrock.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "bedrock" {
  name = "bedrock-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["bedrock:InvokeModel"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "${var.bedrockS3ARN}" ###aws_s3_bucket.bedrock.arn ###### ARN of the S3 bucket that was
      },
      {
        Action = [
          "aoss:APIAccessAll",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:aoss:uk-west-2:${var.awsAccountId}:collection/*"
      },

    ]
  })
}