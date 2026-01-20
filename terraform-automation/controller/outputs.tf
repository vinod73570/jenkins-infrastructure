
output "jenkins_url" {
  value = "http://${aws_instance.jenkins_controller.public_ip}:8080"
}
