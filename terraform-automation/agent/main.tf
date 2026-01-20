



resource "aws_instance" "jenkins_agent" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.jenkins_agent_profile.name
  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]

  user_data = file("user-data.sh")

  tags = {
    Name = "jenkins-agent"
  }
}
