resource "aws_iam_role" "bedrock_role" {
  name = "bedrock_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": {
            "Service": "bedrock.amazonaws.com"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
            "StringEquals": {
                "aws:SourceAccount": "${var.awsAccountId}"
            },
            "ArnLike": {
                "AWS:SourceArn": "arn:aws:bedrock:${var.awsRegion}:${var.awsAccountId}:knowledge-base/*"
            }
        }
    }]
  })
}

resource "aws_iam_role_policy" "bedrock_policy" {
  name = "bedrock_policy"
  role = aws_iam_role.bedrock_role.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "bedrock:ListFoundationModels",
                "bedrock:ListCustomModels"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "bedrock:InvokeModel"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "S3ListBucketStatement",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": ["${var.bedrockS3ARN}"]
        },
        {
            "Sid": "S3GetObjectStatement",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": ["${var.bedrockS3ARN}/*"]
        },
        {
            Action = [
              "secretsmanager:GetSecretValue",
            ]
            Effect   = "Allow"
            Resource = var.pinecone_apikey_secret_arn
        },
    ]
  })
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_execution_role.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "bedrock:StartIngestionJob"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "bedrock:AssociateThirdPartyKnowledgeBase"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]    
  })
}