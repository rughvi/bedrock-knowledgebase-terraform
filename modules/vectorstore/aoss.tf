terraform {
   required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.2.0"
    }
  }
}

data "aws_caller_identity" "current" {}

# Creates a collection
resource "aws_opensearchserverless_collection" "collection" {
  name             = "${local.env.sid}-collection"
  type             = "VECTORSEARCH"
  standby_replicas = "DISABLED"

  depends_on = [aws_opensearchserverless_access_policy.data_access_policy, 
    aws_opensearchserverless_security_policy.encryption_policy, 
    aws_opensearchserverless_security_policy.network_policy]
}

# Creates an encryption security policy
resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  name        = "${local.env.sid}-encryption-policy"
  type        = "encryption"
  description = "encryption policy for ${local.env.sid}-collection"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${local.env.sid}-collection"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

# Creates a network security policy
resource "aws_opensearchserverless_security_policy" "network_policy" {
  name        = "${local.env.sid}-network-policy"
  type        = "network"
  description = "public access for dashboard, VPC access for collection endpoint"
  policy = jsonencode([
    {
      Description = "Public access for dashboards and collection",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.env.sid}-collection"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${local.env.sid}-collection"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

# Creates a data access policy
resource "aws_opensearchserverless_access_policy" "data_access_policy" {
  name        = "${local.env.sid}-data-access-policy"
  type        = "data"
  description = "allow index and collection access"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${local.env.sid}-collection/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.env.sid}-collection"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        data.aws_caller_identity.current.arn,        
        "${var.bedrockIAMRole}"
      ]
    }
  ])
}

resource "opensearch_index" "vector_index" {
  name = local.aoss.vector_index
  index_knn = true
  mappings = jsonencode({
    properties = {
      "${local.aoss.metadata_field}" = {
        type  = "text"
        index = false
      }

      "${local.aoss.text_field}" = {
        type  = "text"
        index = true
      }

      "${local.aoss.vector_field}" = {
        type      = "knn_vector"
        dimension = "${local.aoss.vector_dimension}"
        method = {
          engine = "faiss"
          name   = "hnsw"
        }
      }
    }
  })

  depends_on = [aws_opensearchserverless_collection.collection]
}