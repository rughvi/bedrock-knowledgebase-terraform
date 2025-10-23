resource "aws_s3_bucket" "bedrock" {
  bucket = "vvr-${terraform.workspace}-${var.bedrockS3Bucket}"
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.bedrock.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [
      "GET",
      "PUT",
      "POST",
      "DELETE"
    ]
    allowed_origins = ["*"]
  }
}