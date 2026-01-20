

data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_instance" "jenkins_controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_controller_sg.id]

  user_data = file("user-data.sh")

  tags = {
    Name = "jenkins-controller"
  }
}

