data "aws_bedrock_foundation_model" "embedding" {
  model_id = "amazon.titan-embed-text-v2:0"
}

resource "aws_bedrockagent_knowledge_base" "this" {
  name     = "test-kb"
  role_arn = var.bedrockIAMRoleArn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.embedding.model_arn
    }
  }

  storage_configuration {
    type = "PINECONE"
    pinecone_configuration {
      connection_string    = "${var.pinecone_host}"
      credentials_secret_arn = "${var.pinecone_apikey_secret_arn}"
      field_mapping {
        text_field     = "question"
        metadata_field = "metadata"
      }
    }    
  }
}

resource "aws_bedrockagent_data_source" "this" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id
  name              = "test-s3-001"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.aws_s3_bucket_arn
    }
  }

  depends_on = [aws_bedrockagent_knowledge_base.this]
}