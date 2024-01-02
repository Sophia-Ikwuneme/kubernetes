output "vpc-id" {
  value = aws_vpc.vpc.id
}
output "key-name" {
  value = aws_key_pair.keypair.key_name
}
output "key-id" {
  value = aws_key_pair.keypair.id
}
output "private-key" {
  value = tls_private_key.keypair-1.private_key_pem
}
output "public-subnet1" {
  value = aws_subnet.public-subnet-1.id
}
output "public-subnet2" {
  value = aws_subnet.public-subnet-2.id
}
output "public-subnet3" {
  value = aws_subnet.public-subnet-3.id
}
output "private-subnet1" {
  value = aws_subnet.private-subnet-1.id
}
output "private-subnet2" {
  value = aws_subnet.private-subnet-2.id
}
output "private-subnet3" {
  value = aws_subnet.private-subnet-3.id
}
output "ansible-sg" {
  value = aws_security_group.ansible-sg.id
}
output "kube-nodes-sg" {
  value = aws_security_group.kube-nodes-sg.id
}
output "bastion-sg" {
  value = aws_security_group.bastion-sg.id
}
