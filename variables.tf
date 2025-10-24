variable "bedrockS3Bucket" {
    type = string
    default = "bedrock"
}

variable "awsAccountId" {
    type = string
}

variable "pinecone_host" {
    type = string
}

variable "pinecone_apikey_secret_arn" {
    type = string
}