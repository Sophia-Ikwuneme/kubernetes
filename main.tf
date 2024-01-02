locals {
  name = "sophie"
}
module "vpc" {
  source               = "./module/vpc"
  vpc_cidr             = "10.0.0.0/16"
  keypair              = "keypair-1"
  AZ1                  = "eu-west-2a"
  AZ2                  = "eu-west-2b"
  AZ3                  = "eu-west-2c"
  PSN1_cidr            = "10.0.1.0/24"
  PSN2_cidr            = "10.0.2.0/24"
  PSN3_cidr            = "10.0.3.0/24"
  PrSN1_cidr           = "10.0.4.0/24"
  PrSN2_cidr           = "10.0.5.0/24"
  PrSN3_cidr           = "10.0.6.0/24"
  all_cidr             = "0.0.0.0/0"
  tag-vpc              = "${local.name}-vpc"
  tag-keypair          = "${local.name}-keypair"
  tag-subnet-1         = "${local.name}-public-subnet-1"
  tag-subnet-2         = "${local.name}-public-subnet-2"
  tag-subnet-3         = "${local.name}-public-subnet-3"
  tag-private-subnet-1 = "${local.name}-private-subnet-1"
  tag-private-subnet-2 = "${local.name}-private-subnet-2"
  tag-private-subnet-3 = "${local.name}-private-subnet-3"
  tag-igw              = "${local.name}-igw"
  tag-ngw              = "${local.name}-ngw"
  tag-public_rt        = "${local.name}-public_rt"
  tag-private_rt       = "${local.name}-private_rt"
  tag-ansible-sg       = "${local.name}-ansible-sg"
  tag-bastion-sg       = "${local.name}-bastion-sg"
  tag-kube-nodes-sg    = "${local.name}-kube-nodes-sg"
}
module "master-nodes" {
  source           = "./module/master-nodes"
  count-mstr-nodes = 3
  ami              = "ami-08c3913593117726b"
  instance_type    = "t2.medium"
  subnet_id        = [module.vpc.private-subnet1, module.vpc.private-subnet2, module.vpc.private-subnet3]
  security_groups  = module.vpc.kube-nodes-sg
  key_name         = module.vpc.key-id
  tag-master-nodes = "${local.name}-master-nodes"
}
module "worker-nodes" {
  source            = "./module/worker-nodes"
  count-workr-nodes = 3
  ami               = "ami-08c3913593117726b"
  instance_type     = "t2.medium"
  subnet_id         = [module.vpc.private-subnet1, module.vpc.private-subnet2, module.vpc.private-subnet3]
  security_groups   = module.vpc.kube-nodes-sg
  key_name          = module.vpc.key-id
  tag-worker-nodes  = "${local.name}-worker-nodes"
}
module "bastion-host" {
  source               = "./module/bastion-host"
  ami                  = "ami-08c3913593117726b"
  security_groups      = module.vpc.bastion-sg
  instance_type        = "t2.micro"
  subnet_id            = module.vpc.public-subnet1
  key_name             = module.vpc.key-id
  tag-bastion-host     = "${local.name}-bastion-host"
  private_keypair_path = module.vpc.private-key
}
module "ansible" {
  source             = "./module/ansible"
  ami                = "ami-0e5f882be1900e43b"
  instance_type      = "t2.micro"
  security_group_ids = module.vpc.ansible-sg
  subnet_id          = module.vpc.private-subnet1
  key_name           = module.vpc.key-id
  priv-key           = module.vpc.private-key
  HAproxy1-IP        = module.HAProxy1.HAProxy1-ip
  HAproxy2-IP        = module.HAProxy1.HAProxy1-backup-ip
  master1-IP         = module.master-nodes.master-nodes-ip[0]
  master2-IP         = module.master-nodes.master-nodes-ip[1]
  master3-IP         = module.master-nodes.master-nodes-ip[2]
  worker1-IP         = module.worker-nodes.worker-nodes-ip[0]
  worker2-IP         = module.worker-nodes.worker-nodes-ip[1]
  worker3-IP         = module.worker-nodes.worker-nodes-ip[2]
  tag-ansible-server = "${local.name}-ansible-server"
  bastion_host       = module.bastion-host.bastion-host-ip
}

module "HAProxy1" {
  source              = "./module/HAProxy1"
  ami                 = "ami-08c3913593117726b"
  instance_type       = "t2.medium"
  security_group_ids  = module.vpc.kube-nodes-sg
  subnet_id1          = module.vpc.private-subnet1
  subnet_id2          = module.vpc.private-subnet2
  key_name            = module.vpc.key-name
  master1             = module.master-nodes.master-nodes-ip[0]
  master2             = module.master-nodes.master-nodes-ip[1]
  master3             = module.master-nodes.master-nodes-ip[2]
  tag-HAProxy1        = "${local.name}-HAProxy1"
  tag-HAProxy1-backup = "${local.name}-HAProxy1-backup"
}

module "route53" {
  source                 = "./module/route53"
  domain-name            = "sophieplace.com"
  domain-name1           = "stage.sophieplace.com"
  stage_lb_dns_name      = module.environment-lb.stage-alb-dns
  stage_lb_zoneid        = module.environment-lb.stage-alb-zone-id
  domain-name2           = "prod.sophieplace.com"
  prod_lb_dns_name       = module.environment-lb.prod-lb-dns
  prod_lb_zoneid         = module.environment-lb.prod-lb-zone-id
  domain-name3           = "grafana.sophieplace.com"
  grafana_lb_dns_name    = module.monitor-lb.grafana-dns-name
  grafana_lb_zoneid      = module.monitor-lb.grafana-zone-id
  domain-name4           = "prometheus.sophieplace.com"
  prometheus_lb_dns_name = module.monitor-lb.prometheus-dns-name
  prometheus_lb_zoneid   = module.monitor-lb.prometheus-zone-id
}

module "ssl" {
  source       = "./module/ssl"
  domain_name  = "sophieplace.com"
  domain_name2 = "*.sophieplace.com"
}

module "environment-lb" {
  source             = "./module/environment-lb"
  subnet_id          = [module.vpc.public-subnet1, module.vpc.public-subnet2, module.vpc.public-subnet3]
  tag-prod-alb       = "${local.name}-prod-alb"
  certificate_arn    = module.ssl.certificate_arn
  vpc_id             = module.vpc.vpc-id
  security_group_ids = [module.vpc.kube-nodes-sg]
  tag-stage-alb      = "${local.name}-stage-alb"
  worker_node1    = module.worker-nodes.worker-nodes-id[0]
  worker_node2    = module.worker-nodes.worker-nodes-id[1]
  worker_node3    = module.worker-nodes.worker-nodes-id[2]
}

module "monitor-lb" {
  source             = "./module/monitor-lb"
  subnet_id          = [module.vpc.public-subnet1, module.vpc.public-subnet2, module.vpc.public-subnet3]
  vpc_id             = module.vpc.vpc-id
  security_group_ids = [module.vpc.kube-nodes-sg]
  certificate_arn    = module.ssl.certificate_arn
  worker_node1       = module.worker-nodes.worker-nodes-id[0]
  worker_node2       = module.worker-nodes.worker-nodes-id[1]
  worker_node3       = module.worker-nodes.worker-nodes-id[2]
}

module "jenkins" {
  source = "./module/jenkins"
  key_name = module.vpc.key-id
  vpc = module.vpc.vpc-id
  subnet = module.vpc.public-subnet1
}