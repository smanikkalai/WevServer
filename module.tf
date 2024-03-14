//providers : AWS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
  backend "s3" {
    bucket = "test19765"
    key    = "terraform.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

// module ec2
module "ec2" {
  source = "./ec2-module"
}



