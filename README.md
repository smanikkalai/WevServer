Deploying E-Commerce Application Using Terraform and GitHub Actions.





Deploying a web server using Terraform involves several steps, including defining the infrastructure as code, provisioning resources, and managing configurations. Below is a general outline of how you can deploy a web server using Terraform:
Define Provider:
Start by defining the cloud provider you want to use. For example, if you're deploying to AWS, you'll define the AWS provider in your Provioder.tf file:
//providers : AWS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
}









provider "aws" {
  region = "us-east-1"
}
To deploy an EC2 instance using a module in Terraform, you can organize your Terraform configuration into modules. This allows for better organization, reusability, and maintainability of your infrastructure code. Below is an example of how to create a Terraform module for deploying an EC2 instance:
// module ec2.
module "ec2" {
  source = "./ec2-module"
}
To use an S3 bucket as a backend for storing Terraform state, you need to configure Terraform to save its state file (terraform. tfstate) in an S3 bucket. This allows for better collaboration, state locking, and centralized storage of the Terraform state. Here's how you can set it up:
terraform {
  backend "s3" {
    bucket = "Statefilestoragebox"
    key    = "Github/terraform.tfstate"
    region = "us-east-1"
  }
}








Defining Variables:
You can define variables in your Terraform configuration using the variable block. Variables can have default values and descriptions to make your configuration more self-documenting.
Example:

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








Define Security Group:
Create a new Terraform configuration file (e.g., security_group.tf) and define your security group using the aws_security_group resource based on your local IP.
##############################################################################################################################

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_security_group" "sg" {
  name        = "allow_ssh_http"
  description = "Allow ssh http inbound traffic"
  vpc_id      = aws_vpc.vnet.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${chomp(data.http.myip.response_body)}/32"]
  }

  // Ingress rule allowing traffic from local IP
  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = var.default_tags
}





##############################################################################################################################
Outputs in Terraform provide a convenient way to extract and use specific information from your infrastructure, enabling better visibility and integration with other tools and processes.
output "webServer" {
    value = aws_instance.web_instance.*.public_ip
}

output "nat_gateway_public_ip" {
    value = aws_eip.eip.public_ip
}

output "private_key_file" {
  value = local_file.private_key_file.content
  description = "Path to the generated private key file"
  sensitive = true
}







In Terraform, you can define a Virtual Private Cloud (VPC) using the aws_vpc resource. A VPC allows you to create a logically isolated section of the AWS cloud where you can launch AWS resources in a virtual network that you define. Here's how you can define and configure a VPC using Terraform:
# VPC creations
resource "aws_vpc" "vnet"{
    cidr_block = "10.0.0.0/16"
    tags = var.default_tags
}

# SUBNET-creations-PublicA
resource "aws_subnet" "subnet" {
    count = var.instances_per_subnet
    vpc_id = aws_vpc.vnet.id
    cidr_block = "${cidrsubnet(var.vpc, 8, count.index)}"
    availability_zone = "us-east-1a"
    tags = var.default_tags

}

# InternetGateWay
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vnet.id
    tags = var.default_tags

}

# Elastic-IP
resource "aws_eip" "eip" {
    depends_on                = [aws_internet_gateway.igw]
    tags = var.default_tags
}

# NAT
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.subnet[0].id
    tags = var.default_tags
}

resource "aws_route_table" "igw-rt" {
    vpc_id = aws_vpc.vnet.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id  # Corrected resource name
    }
    tags = var.default_tags
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vnet.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = var.default_tags
}






#Association Between route-table and subnets

# aws_subnet_route_table_association
resource "aws_route_table_association" "associate1" {
    subnet_id = aws_subnet.subnet[0].id
    route_table_id = aws_route_table.igw-rt.id
}

resource "aws_route_table_association" "associate2" {
    subnet_id = aws_subnet.subnet[1].id
    route_table_id = aws_route_table.igw-rt.id
}






To create an EC2 instance using Terraform, you'll need to define an EC2 resource block in your Terraform configuration. In AWS, a key pair is used to securely connect to your EC2 instances. When you create an EC2 instance, you can specify a key pair, and AWS will associate the public key with the instance. You can then use the corresponding private key to authenticate and connect to the instance securely via SSH.
Here's a step-by-step guide:
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]  # Canonical's AWS account ID for Ubuntu
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}






# Generate SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

// creating two instances
resource "aws_instance" "web_instance" {
  count = var.instances_per_subnet
  ami           = var.aws_ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.id
  subnet_id                   = element(aws_subnet.subnet[*].id, count.index % length(aws_subnet.subnet[*].id))
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  user_data                   = base64encode(file("ec2-module/script.sh", {}))
  tags = var.default_tags
}






# Output Private Key to a File
resource "local_file" "private_key_file" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "private_key.pem"
}




The script is below,






#/bin/bash
sudo apt-get update -y 
sudo apt-get install software-properties-common -y
sudo apt-get install docker -y && sudo apt-get install docker-compose -y
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock
mkdir WebServer && cd WebServer
git clone https://github.com/evershopcommerce/evershop.git
sleep 30
cd evershop
docker-compose up -d
sleep 45
exec > > (tee -i /var/log/user-data.log)
exec 2>&1
If you want to save the private key of an AWS key pair as an artifact in GitHub, you can follow these general steps:

    - name: Upload EC2 Key as Artifact
      uses: actions/upload-artifact@v2
      with:
        name: ec2-private-key
        path: private_key.pem  












To create a GitHub Actions workflow for deploying infrastructure with Terraform, you need to define a YAML file within your repository's .github/workflows directory. This YAML file will contain the steps to execute the Terraform commands. Here's a basic example:
name: 'Terraform'

on:
  push:
    branches: [ "stage" ]
  pull_request:

permissions:
  contents: read

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: production

    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v3

    # Set up AWS credentials
    - name: Set up AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    # Install the latest version of Terraform CLI
    - name: Install Terraform
      run: |
        wget https://releases.hashicorp.com/terraform/0.15.0/terraform_0.15.0_linux_amd64.zip
        unzip terraform_0.15.0_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
        terraform --version
    # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
    - name: Terraform Init
      run: terraform init

    # Checks that all Terraform configuration files adhere to a canonical format
    # - name: Terraform Format
    #   run: terraform fmt -check

    # Generates an execution plan for Terraform
    - name: Terraform Plan
      run: terraform plan -input=false

    # On push to "stage", build or change infrastructure according to Terraform configuration files
    # # Note: It is recommended to set up a required "strict" status check in your repository for "Terraform Cloud". See the documentation on "strict" required status checks for more information: https://help.github.com/en/github/administering-a-repository/types-of-required-status-checks
    - name: Terraform Apply
      if: github.ref == 'refs/heads/stage' && github.event_name == 'push'
      run: terraform apply -auto-approve -input=false

    # - name: Terraform Destroy
    #   if: github.ref == 'refs/heads/stage' && github.event_name == 'push'
    #   run: terraform destroy -auto-approve -input=false

    - name: Upload EC2 Key as Artifact
      uses: actions/upload-artifact@v2
      with:
        name: ec2-private-key
        path: private_key.pem







To run the GitHub Actions workflow you've defined, you simply need to push your changes to the main branch of your repository. Here's a quick recap of the steps:
If you want to check the status of your local Git repository, you can use the git status command. This command shows you information about which files have been modified, staged, or are untracked in your working directory. Here's how you can use it:
The git add . command is used to stage all changes in your working directory for the next commit. This includes new files, modified files, and deleted files. Here's how you can use it:


To commit changes to your local Git repository,


you use the git commit -m "...." command. This command captures the changes you've staged using git add and creates a new commit with a message describing the changes. Here's how you can use it:


To push your committed changes from your local Git repository to a remote repository (such as one hosted on GitHub), you use the git push command. Here's how to do it:
1. Go to GitHub Actions, You can see that the applying resource details in AWS.
2. The private key has been saved into the artifact
3. How to get the Private key in Local after deployment;
4. You can choose the summary option in Git Hub and download the key file.
5. Now, You can see the Instances in the AWS console,
6. Here, you can see the webserver is hosting the website;
Done.