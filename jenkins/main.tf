#Creating jenkins server
resource "aws_instance" "jenkins_server" {
  ami                         = "ami-07fb9d5c721566c65"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keypair-2.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile2.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  user_data                   = local.jenkins_user_data
    tags = {
    Name = "jenkins"
  }
}
# RSA key of size 4096 bits
resource "tls_private_key" "keypair-2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
#creating private key
resource "local_file" "keypair-2" {
 content = tls_private_key.keypair-2.private_key_pem
 filename = "jenkins-key"
 file_permission =  "600"
}
#Creating an EC2 keypair
resource "aws_key_pair" "keypair-2" {
  key_name   = "jenkins-key"
  public_key = tls_private_key.keypair-2.public_key_openssh
  tags = {
    Name = "jenkins-key"
  }
}
# Security Group for Jenkins Server
resource "aws_security_group" "jenkins_sg" {
  name        = "${local.name}-jenkins_sg"
  description = "Allow inbound traffic" 
  ingress {
    description = "SSH access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.all_cidr
  }
  ingress {
    description = "HTTP access"
    from_port   = var.port_8080
    to_port     = var.port_8080
    protocol    = "tcp"
    cidr_blocks = var.all_cidr
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.name}-jenkins_sg"
  }
}

# Create IAM Policy
resource "aws_iam_role_policy" "ec2_policy2" {
  name = "ec2_policy2"
  role = aws_iam_role.ec2_role2.id
  policy = "${file("${path.root}/ec2-policy.json")}"
}
# Create IAM Role
resource "aws_iam_role" "ec2_role2" {
  name = "ec2_role3"
  assume_role_policy = "${file("${path.root}/ec2-assume.json")}"
}
# Create IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile2" {
  name = "ec2_profile3"
  role = aws_iam_role.ec2_role2.name
}