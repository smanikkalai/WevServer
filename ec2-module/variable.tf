
#############################VARIABLS#####################################
##########################################################################

variable "region" {
    type = string
    default = "us-east-1"
}

variable "vpc" {
    default = "10.0.0.0/16"
}

variable "instance_name" {
        description = "Name of the instance to be created"
        default = "aws-demo" 
}

variable "aws_ami" {
        description = "Name of the instance to be created"
        default = "ami-07d9b9ddc6cd8dd30"
}

variable "instance_type" {
        default = "t2.micro"
}



variable "instances_per_subnet" {
  description = "Number of EC2 instances in each private subnet"
  type        = number
  default     = 2
}

variable "default_tags" {
  type    = map(string)
  default = {
    Name        = "WebServer"
    Environment = "Production"
    Owner       = "SelvarajManikkalai"
    Platform    = "IAAS"
  }
}

