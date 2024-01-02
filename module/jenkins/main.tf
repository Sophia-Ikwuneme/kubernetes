#Creating jenkins server
resource "aws_instance" "jenkins_server" {
  ami                         = "ami-07fb9d5c721566c65"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = var.subnet
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  user_data                   = local.jenkins_user_data
    tags = {
    Name = "jenkins2"
  }
}

 #Security Group for Jenkins Server
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow inbound traffic" 
  vpc_id = var.vpc
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins_sg"
  }
}