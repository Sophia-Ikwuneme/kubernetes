# Create three EC2 instances in the respective subnets
resource "aws_instance" "worker-nodes" {
  count = var.count-workr-nodes
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_id, count.index)
  vpc_security_group_ids = [ var.security_groups ]
  key_name      = var.key_name

tags = {
    name = var.tag-worker-nodes
}
}