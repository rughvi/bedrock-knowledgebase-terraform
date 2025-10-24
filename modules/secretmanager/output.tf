output "pinecone_apikey_secret_arn" {
    value = aws_secretsmanager_secret.pinecone_apikey_secret.arn
}