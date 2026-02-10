#!/bin/bash
set -e

# ----------------------------
# System update
# ----------------------------
apt update -y
apt upgrade -y



# ----------------------------
# Install dependencies
# ----------------------------
apt install -y ca-certificates curl gnupg

# ----------------------------
# Add Jenkins GPG key
# ----------------------------
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
 | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# ----------------------------
# Add Jenkins repository
# ----------------------------
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
 | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# ----------------------------
# Install Jenkins
# ----------------------------
apt update -y
apt install -y jenkins

# ----------------------------
# Enable & start Jenkins
# ----------------------------
systemctl enable jenkins
systemctl start jenkins
