output "master-nodes-ip" {
  value = aws_instance.master-nodes.*.private_ip
}