##############################################################################################################################


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
