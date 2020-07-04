variable "vpc_cidr" {
  description = "cidr block for vpc"
}
variable "public_cidr" {
  description = "cidr block for public subnet"
}
variable "private_cidr" {
  description = "cidr block for private subnet"
}
variable "customer_name" {
  description = "customer name for tag"
}
variable "public_ingress_ports" {
  description = "ingress ports for public security group"
  type = list(number)
  default = [22,80]
}