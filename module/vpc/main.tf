#Creating a VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.tag-vpc
  }
}

# RSA key of size 4096 bits
resource "tls_private_key" "keypair-1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#creating private key
resource "local_file" "keypair-1" {
 content = tls_private_key.keypair-1.private_key_pem
 filename = "keypair"
 file_permission =  "600"
}

#Creating an EC2 keypair
resource "aws_key_pair" "keypair" {
  key_name   = var.keypair
  public_key = tls_private_key.keypair-1.public_key_openssh
  tags = {
    Name = var.tag-keypair
  }
}

#create 3 public subnets 
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ1
  cidr_block        = var.PSN1_cidr

  tags = {
    Name = var.tag-subnet-1
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ2
  cidr_block        = var.PSN2_cidr

  tags = {
    Name = var.tag-subnet-2
  }
}

resource "aws_subnet" "public-subnet-3" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ3
  cidr_block        = var.PSN3_cidr

  tags = {
    Name = var.tag-subnet-3
  }
}

#create 3 private subnets 
resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ1
  cidr_block        = var.PrSN1_cidr

  tags = {
    Name = var.tag-private-subnet-1
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ2
  cidr_block        = var.PrSN2_cidr

  tags = {
    Name = var.tag-private-subnet-2
  }
}

resource "aws_subnet" "private-subnet-3" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.AZ3
  cidr_block        = var.PrSN3_cidr

  tags = {
    Name = var.tag-private-subnet-3
  }
}

#Creating Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.tag-igw
  }
}

#Creating elastic ip
resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

#Creating nat gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = var.tag-ngw
  }
}

# creating a public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.tag-public_rt
  }
}

# attaching public subnet 1 to public route table
resource "aws_route_table_association" "public_rt_SN1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public_rt.id
}

# attaching public subnet 2 to public route table
resource "aws_route_table_association" "public_rt_SN2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public_rt.id
}

# attaching public subnet 3 to public route table
resource "aws_route_table_association" "public_rt_SN3" {
  subnet_id      = aws_subnet.public-subnet-3.id
  route_table_id = aws_route_table.public_rt.id
}

# creating a private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.all_cidr
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = var.tag-private_rt
  }
}

# attaching private subnet 1 to private route table
resource "aws_route_table_association" "private_rt_SN1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private_rt.id
}

# attaching private subnet 2 to private route table
resource "aws_route_table_association" "private_rt_SN2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private_rt.id
}

# attaching private subnet 3 to private route table
resource "aws_route_table_association" "private_rt_SN3" {
  subnet_id      = aws_subnet.private-subnet-3.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Group for Ansible Server
resource "aws_security_group" "ansible-sg" {
  name        = "ansible"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.tag-ansible-sg
  }
}

# Security Group for kube-nodes
resource "aws_security_group" "kube-nodes-sg" {
  name        = "kube-nodes"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
   description = "SSH access"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.tag-kube-nodes-sg
  }
}

# Security Group for bastion-host
resource "aws_security_group" "bastion-sg" {
  name        = "bastion"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.tag-bastion-sg
  }
}

# #Security group for Masters/worker node
# resource "aws_security_group" "mas_work_sg" {
#   name = "mas_work_sg"
#   description = "Allow inbound Traffic"
#   vpc_id = aws_vpc.vpc.id

#   ingress {
#     description = "Http Proxy"
#     from_port = var.port_proxy
#     to_port = var.port_proxy
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }
#    ingress {
#     description = "Http80"
#     from_port = var.port_proxy3
#     to_port = var.port_proxy3
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }
#   ingress {
#     description = "ssh access"
#     from_port = var.port_ssh
#     to_port = var.port_ssh
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }

#   ingress {
#     from_port = var.port_proxy2
#     to_port = var.port_proxy2
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }

#     ingress { 
#     from_port = var.port_app
#     to_port = var.port_app
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }

#    ingress { 
#     from_port = var.port_https
#     to_port = var.port_https
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }

#     ingress { 
#     from_port = var.port_graf
#     to_port = var.port_graf
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }

#     ingress { 
#     from_port = var.port_prom
#     to_port = var.port_prom
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }
#     ingress { 
#     from_port = var.port_etcd
#     to_port = var.port_prom
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }
#     ingress { 
#     from_port = var.port_etcd_client
#     to_port = var.port_prom
#     protocol = "tcp"
#     cidr_blocks =[var.all_cidr]
#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [var.all_cidr]
#   }

#   tags = {
#     Name = var.mas_work_sg
#   }
# }