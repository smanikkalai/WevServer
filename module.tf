//providers : AWS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }

  backend "s3" {
    bucket         	   = "mycomponents-tfstate"
    key              	   = "state/terraform.tfstate"
    region         	   = "us-east-1"
    encrypt        	   = true
    dynamodb_table = "mycomponents_tf_lockid"
  }
}

provider "aws" {
  region = "us-east-1"
}

// module ec2
module "ec2" {
  source = "./ec2-module"
}



