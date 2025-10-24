output "vector_index" {
    value = local.aoss.vector_index
}

output "vector_field" {
    value = local.aoss.vector_field
}

output "text_field" {
    value = local.aoss.text_field
}

output "metadata_field" {
    value = local.aoss.metadata_field
}

output "aossCollectionArn" {
    value= aws_opensearchserverless_collection.collection.arn
}