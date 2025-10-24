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

module "secretmanager" {
  source = "./modules/secretmanager"
  pinecone_apikey_seceret_value=var.pinecone_apikey
}

module "iam" {
  source = "./modules/iam"
  awsAccountId = var.awsAccountId
  bedrockS3ARN = module.s3.aws_s3_bucket_arn
  awsRegion = local.env.region_name
  pinecone_apikey_secret_arn = module.secretmanager.pinecone_apikey_secret_arn
  depends_on = [module.s3, module.secretmanager]
}

resource "time_sleep" "timesleep" {
  create_duration = "20s"
  depends_on      = [module.iam]
}

module "bedrock" {
  source = "./modules/bedrock"
  bedrockIAMRoleArn = module.iam.bedrockIAMRoleArn
  aws_s3_bucket_arn = module.s3.aws_s3_bucket_arn
  pinecone_host= var.pinecone_host
  pinecone_apikey_secret_arn = module.secretmanager.pinecone_apikey_secret_arn
  depends_on = [module.s3, module.iam, module.secretmanager, time_sleep.timesleep]
}