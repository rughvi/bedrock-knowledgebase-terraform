output "bedrock_knowledgebase_id" {
    value = aws_bedrockagent_knowledge_base.bedrock_knowledgebase.id
}

output "bedrock_knowledgebase_datasource_id" {
    value = aws_bedrockagent_data_source.bedrock_datasource.id
}