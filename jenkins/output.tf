output "jenkins-server-ip" {
  value = aws_instance.jenkins_server.public_ip
}
