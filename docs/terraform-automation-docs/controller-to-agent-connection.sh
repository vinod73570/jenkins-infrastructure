🔹 JENKINS CONTROLLER ↔ AGENT
Exact Steps We Followed (Chat Replay Blueprint)
1️⃣ Create Jenkins Controller (Ubuntu)

OS

Ubuntu 22.04

User-data used

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y fontconfig openjdk-17-jdk

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


Verify

sudo systemctl status jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

2️⃣ Create Jenkins Agent (Ubuntu 24.04)

User-data used

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y \
  ca-certificates \
  curl \
  gnupg \
  unzip \
  git \
  lsb-release

sudo apt install -y openjdk-17-jre

sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

curl -fsSL https://apt.releases.hashicorp.com/gpg \
 | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt update -y
sudo apt install -y terraform

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install

3️⃣ Generate SSH Key on Controller (NO passphrase)
sudo -u jenkins ssh-keygen \
 -t rsa -b 4096 \
 -f /var/lib/jenkins/.ssh/agent-key \
 -N ""

4️⃣ Copy Public Key to Agent

On controller

sudo cat /var/lib/jenkins/.ssh/agent-key.pub


On agent

mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys   # paste key
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

5️⃣ Manual SSH Test (Critical Step)
sudo -u jenkins bash
ssh ubuntu@<AGENT_PRIVATE_IP>


✅ This must work before Jenkins config.

6️⃣ Create Jenkins Credential

Manage Jenkins → Credentials → Global → Add

Kind: SSH Username with private key

Username: ubuntu

Private key:
paste:

sudo cat /var/lib/jenkins/.ssh/agent-key


Scope: Global

7️⃣ Create Jenkins Node

Manage Jenkins → Nodes → New Node

Name: terraform-agent

Type: Permanent

Remote root:

/home/ubuntu


Labels:

terraform docker aws


Launch method: SSH

Host: <AGENT_PRIVATE_IP>

Credentials: ubuntu

Host key verification:

Non verifying Verification Strategy

8️⃣ Fix known_hosts Issue (Exact Commands)
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins touch /var/lib/jenkins/.ssh/known_hosts
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo chmod 700 /var/lib/jenkins/.ssh
sudo chmod 600 /var/lib/jenkins/.ssh/known_hosts


Correct way to add host:

ssh-keyscan <AGENT_PRIVATE_IP> | sudo -u jenkins tee -a /var/lib/jenkins/.ssh/known_hosts

9️⃣ Debug Errors We Hit (Real Sequence)
❌ Agent stuck (launching…)

Cause: wrong user (ec2-user)

Fix: use ubuntu

❌ Credentials not found

Cause: Jenkins credential ID mismatch

Fix: recreate node

❌ SSH works but Jenkins fails

Cause: encrypted SSH key

Fix: generate key with -N ""

❌ Key exchange failed

Cause: missing /var/lib/jenkins/.ssh/known_hosts

Fix: create file + ssh-keyscan

❌ Final blocker
java: command not found
Agent JVM has terminated


Cause: Java missing on agent

Fix:

sudo apt install -y openjdk-17-jre

🔟 Final State Achieved

Jenkins Controller → online

Jenkins Agent → online

SSH → stable

Java → present

Agent visible with disk + architecture

Ready for Terraform pipelines