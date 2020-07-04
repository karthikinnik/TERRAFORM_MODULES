output "aws_vpc_id" {
  value = aws_vpc.vpc.id
}
output "vpc_public_subnet" {
  value = aws_subnet.public_subnet.id
}
output "vpc_private_subnet" {
  value = aws_subnet.private_subnet.id
}
output "public_security_group" {
  value = aws_security_group.public_dynamic_sg.id
}
output "public_availability_zone" {
  value = aws_subnet.public_subnet.availability_zone
}
output "private_availability_zone" {
  value = aws_subnet.private_subnet.availability_zone
}
