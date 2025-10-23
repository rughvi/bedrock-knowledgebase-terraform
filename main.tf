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

  backend "s3" {
    bucket  = ""
    region  = "eu-west-2"
    key     = "bedrock-one-terraform.tfstate"
    encrypt = true
  }
}