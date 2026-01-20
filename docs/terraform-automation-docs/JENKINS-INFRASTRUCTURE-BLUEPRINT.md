✅ JENKINS INFRASTRUCTURE BLUEPRINT

Controller + Agent (Terraform-provisioned, Ubuntu, SSH-based)

0️⃣ DESIGN DECISIONS (NON-NEGOTIABLE)
Architecture
Jenkins Controller (Ubuntu)
        |
        |  SSH (keys)
        v
Jenkins Agent (Ubuntu 24.04)

Rules

Controller:

❌ No Docker

❌ No AWS permissions

❌ No Terraform

✅ UI + scheduling only

Agent:

✅ Terraform

✅ AWS CLI

✅ Docker (later use)

✅ Java (MANDATORY)

Auth:

SSH key-based (no passwords)

IAM Role on agent (no AWS keys)

Networking:

Same VPC

Private IP SSH allowed

1️⃣ TERRAFORM LAYER (FOUNDATION)
Folder
infra-jenkins/
├── controller/
│   ├── main.tf
│   ├── variables.tf
│   ├── user-data.sh
│   └── outputs.tf
└── agent/
    ├── main.tf
    ├── variables.tf
    ├── user-data.sh
    └── outputs.tf

2️⃣ JENKINS CONTROLLER (UBUNTU)
OS

Ubuntu 22.04 LTS

Security Group

Inbound:

8080 → Jenkins UI

22 → SSH (admin only)

Outbound:

All

✅ Controller User-Data (FINAL, CORRECT)
#!/bin/bash
set -e

sudo apt update -y
sudo apt upgrade -y

# Java 17 (required by Jenkins)
sudo apt install -y fontconfig openjdk-17-jdk

# Jenkins repo
sudo apt install -y ca-certificates curl gnupg
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins

Verification
sudo systemctl status jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

3️⃣ JENKINS AGENT (UBUNTU 24.04)
OS

Ubuntu 24.04 (noble)

Security Group

Inbound:

22 from controller SG

Outbound:

All (AWS APIs)

✅ Agent User-Data (FINAL)
#!/bin/bash
set -e

sudo apt update -y
sudo apt upgrade -y

# Base tools
sudo apt install -y \
  ca-certificates \
  curl \
  gnupg \
  unzip \
  git \
  lsb-release

# Java (MANDATORY for Jenkins agent)
sudo apt install -y openjdk-17-jre

# Docker (agent only)
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt update -y
sudo apt install -y terraform

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install

Verification
java -version
terraform version
aws --version
docker --version

4️⃣ SSH KEY ARCHITECTURE (CRITICAL)
Generate key on CONTROLLER
sudo -u jenkins ssh-keygen \
  -t rsa -b 4096 \
  -f /var/lib/jenkins/.ssh/agent-key \
  -N ""

Copy public key to AGENT
sudo cat /var/lib/jenkins/.ssh/agent-key.pub


On agent:

mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys   # paste key
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

5️⃣ KNOWN_HOSTS (REAL PRODUCTION FIX)
Why

Jenkins SSH launcher requires:

/var/lib/jenkins/.ssh/known_hosts

Fix (controller)
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins touch /var/lib/jenkins/.ssh/known_hosts
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo chmod 700 /var/lib/jenkins/.ssh
sudo chmod 600 /var/lib/jenkins/.ssh/known_hosts

ssh-keyscan 172.31.22.250 | sudo -u jenkins tee -a /var/lib/jenkins/.ssh/known_hosts

6️⃣ JENKINS NODE CONFIG (FINAL)

Manage Jenkins → Nodes → New Node

Name: terraform-agent

Type: Permanent Agent

Remote root:

/home/ubuntu


Labels:

terraform docker aws


Launch method: SSH

Host: 172.31.22.250

Credentials:

Username: ubuntu

SSH private key (agent-key)

Host key verification:

Known hosts file Verification Strategy

7️⃣ REAL ERRORS WE HIT (AND FIXED)
Problem	Root Cause	Fix
Agent stuck (launching…)	Wrong user (ec2-user)	Use ubuntu
SSH works manually but Jenkins fails	Encrypted key	Use no-passphrase key
credentials not found	Jenkins ID mismatch	Recreate node
known_hosts not found	Jenkins uses /var/lib/jenkins	Create file
java: command not found	Java missing on agent	Install openjdk-17-jre

This list is gold. Save it.

8️⃣ FINAL STATE ACHIEVED

You now have:

✅ Clean Jenkins controller

✅ Secure SSH-connected agent

✅ Java-enabled agent

✅ Terraform-ready CI worker

✅ Recoverable documentation

✅ Production-grade separation of roles

🔒 THIS BLUEPRINT IS NOW YOUR BASELINE

From here:

Any future Jenkins rebuild = 30 minutes

Any teammate can reproduce this

No tribal knowledge left