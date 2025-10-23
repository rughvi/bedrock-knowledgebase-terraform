provider "aws" {
  region = local.env.region_name

  default_tags {
    tags = {
      SID         = local.env.sid
      Environment = local.env.environment
    }
  }
}

provider "opensearch" {
  url        = aws_opensearchserverless_collection.collection.collection_endpoint
  aws_region = local.env.region_name

  healthcheck = false
}