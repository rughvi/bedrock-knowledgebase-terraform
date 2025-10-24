resource "aws_secretsmanager_secret" "pinecone_apikey_secret" {
  name = "PineconeAPIKey"
}

resource "aws_secretsmanager_secret_version" "pinecone_apikey_secret_version" {
  secret_id     = aws_secretsmanager_secret.pinecone_apikey_secret.id
  secret_string = var.pinecone_apikey_seceret_value
}