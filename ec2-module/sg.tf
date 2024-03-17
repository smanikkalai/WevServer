# ##############################################################################################################################

# resource "aws_security_group" "sg" {
#   name        = "allow_ssh_http"
#   description = "Allow ssh http inbound traffic"
#   vpc_id      = aws_vpc.vnet.id

#   ingress {
#     description      = "SSH from VPC"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }


#   // Ingress rule allowing traffic from local IP
#   ingress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["self"]
#   }

#   ingress {
#     description      = "HTTP from VPC"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
#   tags = var.default_tags
# }
# ##############################################################################################################################


// testing

resource "aws_security_group" "s3_access" {
  name        = "s3-access"
  description = "Security group for S3 access"
  vpc_id      = aws_vpc.main.id

  // Ingress rule allowing traffic from local IP
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["self"]
  }

  // Egress rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
