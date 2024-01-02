locals {
jenkins_user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install wget -y
sudo yum install git -y
sudo wget https://get.jenkins.io/redhat/jenkins-2.411-1.1.noarch.rpm
sudo rpm -ivh jenkins-2.411-1.1.noarch.rpm
sudo yum install java-11-openjdk -y
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo hostnamectl set-hostname Jenkins
EOF
}