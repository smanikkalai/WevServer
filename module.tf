//providers : AWS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.38.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

// module ec2
module "vpc" {
  source = "./ec2-module"
}


