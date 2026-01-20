#!/bin/bash
set -e

# ----------------------------
# System update
# ----------------------------
apt update -y
apt upgrade -y

# ----------------------------
# Base required packages
# ----------------------------
apt install -y \
  ca-certificates \
  curl \
  unzip \
  git

# ----------------------------
# Install Terraform (binary, pinned)
# ----------------------------
cd /tmp
curl -LO https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
mv terraform /usr/local/bin/
chmod +x /usr/local/bin/terraform

# Verify Terraform
terraform version

# ----------------------------
# Install AWS CLI v2 (binary)
# ----------------------------
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
./aws/install

# Verify AWS CLI
aws --version

# ----------------------------
# Cleanup
# ----------------------------
rm -rf /tmp/aws /tmp/awscliv2.zip /tmp/terraform_1.6.6_linux_amd64.zip
