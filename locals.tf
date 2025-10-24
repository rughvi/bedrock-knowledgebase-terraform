locals {
  env = {
    environment  = "${terraform.workspace}"
    region_name  = "us-east-1"
    sid          = "${terraform.workspace}"
  }  
}