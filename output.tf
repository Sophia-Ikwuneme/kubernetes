output "ansible-ip" {
  value = module.ansible.ansible-ip
}
output "bastion-ip" {
  value = module.bastion-host.bastion-host-ip
}
output "master-nodes" {
  value = module.master-nodes.master-nodes-ip
}
output "worker-nodes" {
  value = module.worker-nodes.worker-nodes-ip
}
output "HAProxy1-ip" {
  value = module.HAProxy1.HAProxy1-ip
}
output "HAProxy1-backup-ip" {
  value = module.HAProxy1.HAProxy1-backup-ip
}