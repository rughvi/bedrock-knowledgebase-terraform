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
  awsRegion = local.env.region_name
}

module "aoss" {
  source = "./modules/vectorstore"
  bedrockIAMRole = module.iam.bedrockIAMRoleArn
}

module "bedrock" {
  source = "./modules/bedrock"
  vector_index = module.aoss.vector_index
  vector_field = module.aoss.vector_field
  text_field = module.aoss.text_field
  metadata_field = module.aoss.metadata_field
  bedrockIAMRoleArn = module.iam.bedrockIAMRoleArn
  aossCollectionArn = module.aoss.aossCollectionArn
  aws_s3_bucket_arn = module.s3.aws_s3_bucket_arn
  depends_on = [module.s3, module.iam, module.aoss]
}