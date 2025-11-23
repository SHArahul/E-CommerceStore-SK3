variable "aws_region" { default = "ca-central-1" }
variable "instance_type" { default = "t3.micro" }
variable "ssh_key_name" { description = "Rahul_Mykey" }
variable "docker_images" {
type = map(string)
default = {
frontend = "<Rahul_Sharma>/frontend:latest"
user = "<Rahul_Sharma>/user:latest"
products = "<Rahul_Sharma>/products:latest"
orders = "<Rahul_Sharma>/orders:latest"
cart = "<Rahul_Sharma>/cart:latest"
}
}