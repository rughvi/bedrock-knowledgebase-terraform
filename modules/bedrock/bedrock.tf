data "aws_bedrock_foundation_model" "embedding" {
  model_id = "amazon.titan-embed-text-v2:0"
}
resource "aws_bedrockagent_knowledge_base" "this" {
  name     = "test-kb"
  role_arn = var.bedrockIAMRoleArn #iam_role.bedrock.arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.embedding.model_arn
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = var.aossCollectionArn
      vector_index_name = var.vector_index
      field_mapping {
        vector_field   = var.vector_field
        text_field     = var.text_field
        metadata_field = var.metadata_field
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