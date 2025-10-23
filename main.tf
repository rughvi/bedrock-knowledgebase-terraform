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

module "s3" {
  source = "./modules/s3"
  bedrockS3Bucket = "${var.bedrockS3Bucket}"
}

module "iam" {
  source = "./modules/iam"
  awsAccountId = var.awsAccountId
  bedrockS3ARN = module.s3.aws_s3_bucket_arn
}

module "aoss" {
  source = "./modules/vectorstore"
  bedrockIAMRole = module.iam.bedrockIAMRoleArn
}