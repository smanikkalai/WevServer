##############################################################################################################################
# VPC creations
resource "aws_vpc" "vnet"{
    cidr_block = "10.0.0.0/16"
    tags = var.default_tags
}
##############################################################################################################################
# SUBNET-creations-PublicA
resource "aws_subnet" "subnet" {
    count = var.instances_per_subnet
    vpc_id = aws_vpc.vnet.id
    cidr_block = "${cidrsubnet(var.vpc, 8, count.index)}"
    availability_zone = "us-east-1a"
    tags = var.default_tags

}
##############################################################################################################################
# InternetGateWay
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vnet.id
    tags = var.default_tags
}
##############################################################################################################################
# Elastic-IP
resource "aws_eip" "eip" {
    depends_on                = [aws_internet_gateway.igw]
    tags = var.default_tags
}
##############################################################################################################################
# NAT
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.subnet[0].id
    tags = var.default_tags
}
##############################################################################################################################
resource "aws_route_table" "igw-rt" {
    vpc_id = aws_vpc.vnet.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id  # Corrected resource name
    }
    tags = var.default_tags
}
##############################################################################################################################
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vnet.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = var.default_tags
}
##############################################################################################################################
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
##############################################################################################################################

