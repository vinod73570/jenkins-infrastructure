#!/bin/bash
set -e

# ----------------------------
# System update
# ----------------------------
apt update -y
apt upgrade -y

# ----------------------------
# Base packages
# ----------------------------
apt install -y \
  ca-certificates \
  curl \
  gnupg \
  unzip \
  git \
  lsb-release

# ----------------------------
# Java (Agent JVM)
# ----------------------------
apt install -y openjdk-17-jre


# ----------------------------
# Terraform (HashiCorp repo)
# ----------------------------
curl -fsSL https://apt.releases.hashicorp.com/gpg \
 | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
 | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

apt update -y
apt install -y terraform

# ----------------------------
# AWS CLI v2
# ----------------------------
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
./aws/install

# ----------------------------
# Ansible
sudo apt install -y ansible

# ----------------------------
# Cleanup
# ----------------------------
rm -rf /tmp/aws /tmp/awscliv2.zip
