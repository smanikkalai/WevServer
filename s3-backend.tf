terraform {
  backend "s3" {
    bucket = "athenatableacceslaration"
    key    = "Github/terraform.tfstate"
    region = "us-east-1"
  }
}


  
