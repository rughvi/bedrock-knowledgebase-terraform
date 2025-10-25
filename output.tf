output "bedrock_knowledgebase_id" {
    value = module.bedrock.bedrock_knowledgebase_id
}

output "bedrock_datasource_id" {
    value = split(",", module.bedrock.bedrock_datasource_id)[0]
}