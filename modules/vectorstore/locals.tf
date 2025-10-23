locals {
  env = {
    environment  = "${terraform.workspace}"
    region_name  = "eu-west-2"
    sid          = "${terraform.workspace}"
  }
  aoss = {
    vector_index     = "vector_index"
    vector_field     = "vector_field"
    text_field       = "text_field"
    metadata_field   = "metadata_field"
    vector_dimension = 1024
  }
}