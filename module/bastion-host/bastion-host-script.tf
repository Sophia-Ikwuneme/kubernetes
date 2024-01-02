locals {
 bastion-host_user_data = <<-EOF
#!/bin/bash
echo "${var.private_keypair_path}" >> /home/ubuntu/ET2PACAAD
chmod 400 /home/ubuntu/ET2PACAAD
chown ubuntu:ubuntu /home/ubuntu/ET2PACAAD
sudo hostnamectl set-hostname Bastion
EOF
}