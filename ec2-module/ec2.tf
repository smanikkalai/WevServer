data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]  # Canonical's AWS account ID for Ubuntu
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


// creating two instances
resource "aws_instance" "web_instance" {
  count = var.instances_per_subnet
  ami           = var.aws_ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.keys.key_name
  subnet_id                   = element(aws_subnet.subnet[*].id, count.index % length(aws_subnet.subnet[*].id))
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  user_data = <<EOF
  #!/bin/bash
  sudo exec >>(tee -i /var/log/user-data.log)
  sudo exec 2>&1
  sudo apt-get update -y 
  sudo apt-get install software-properties-common -y
  sudo apt-get install docker -y && sudo apt-get install docker-compose -y
  sudo usermod -aG docker $USER
  sudo chmod 777 /var/run/docker.sock
  mkdir WebServer && cd WebServer
  git clone https://github.com/evershopcommerce/evershop.git
  sleep 30
  docker-compose up -d
  sleep 45
  EOF

  tags = var.default_tags
}

resource "tls_private_key" "keys" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keys" {
  key_name   = "keys"       # Create "myKey" to AWS!!
  public_key = tls_private_key.keys.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.keys.private_key_pem}' > ./${var.keys}.pem"
  }
  tags = var.default_tags
}


# Output Private Key to a File
resource "local_file" "private_key_file" {
  content  = tls_private_key.keys.private_key_pem
  filename = "${var.keys}.pem"                      # Save it in
}

output "private_key_file" {
  value = local_file.private_key_file.content
  description = "Path to the generated private key file"
  sensitive = true
}