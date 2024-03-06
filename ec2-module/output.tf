output "webServer" {
    value = aws_instance.web_instance.*.public_ip
}

output "nat_gateway_public_ip" {
    value = aws_eip.eip.public_ip
}

