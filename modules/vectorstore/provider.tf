provider "opensearch" {
  url        = aws_opensearchserverless_collection.collection.collection_endpoint
  aws_region = local.env.region_name

  healthcheck = false
}