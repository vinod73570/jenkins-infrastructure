resource "aws_iam_role" "jenkins_agent_role" {
  name = "jenkins-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.jenkins_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jenkins_agent_profile" {
  name = "jenkins-agent-profile"
  role = aws_iam_role.jenkins_agent_role.name
}
