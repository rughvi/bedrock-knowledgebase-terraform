locals {
  env = {
    environment  = "${terraform.workspace}"
    region_name  = "eu-west-2"
    sid          = "${terraform.workspace}"
  }  
}