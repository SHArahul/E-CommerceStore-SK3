resource "aws_vpc" "this" {
cidr_block = "10.0.0.0/16"
tags = { Name = "ecom-vpc" }
}


resource "aws_subnet" "public" {
vpc_id = aws_vpc.this.id
cidr_block = "10.0.1.0/24"
map_public_ip_on_launch = true
tags = { Name = "ecom-public-subnet" }
}


resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.this.id }


resource "aws_route_table" "public" {
vpc_id = aws_vpc.this.id
route { cidr_block = "0.0.0.0/0"; gateway_id = aws_internet_gateway.igw.id }
}
resource "aws_route_table_association" "rta" { subnet_id = aws_subnet.public.id; route_table_id = aws_route_table.public.id }


resource "aws_security_group" "bastion_sg" {
name = "ecom-sg"
vpc_id = aws_vpc.this.id
ingress = [
{ from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
{ from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
{ from_port = 3001, to_port = 3004, protocol = "tcp", cidr_blocks = ["10.0.0.0/16"] }
]
egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
}


data "aws_ami" "ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical
filter { name = "name"; values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] }
}


resource "aws_instance" "app" {
ami = data.aws_ami.ubuntu.id
instance_type = var.instance_type
subnet_id = aws_subnet.public.id
key_name = var.ssh_key_name
associate_public_ip_address = true
vpc_security_group_ids = [aws_security_group.bastion_sg.id]
user_data = templatefile("${path.module}/userdata.sh.tpl", { images = var.docker_images })
tags = { Name = "ecom-instance" }
}