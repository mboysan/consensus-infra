#!/bin/bash

# -------------------------------------------------- already included
# git

# -------------------------------------------------- iperf (for network performance testing)
sudo apt-get update
sudo apt-get install -y iperf

# -------------------------------------------------- jdk-17
# prepare
sudo mkdir -p /opt/java/latest

# get zulu-jdk
wget https://cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-linux_x64.tar.gz -P /tmp

# un-tar
sudo tar xvf /tmp/zulu*.tar.gz --strip 1 -C /opt/java/latest

# environment variables
echo "" >> ~/.bashrc
echo 'export JAVA_HOME=/opt/java/latest' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source .bashrc

# verify
java --version

# -------------------------------------------------- maven
# prepare
sudo mkdir -p /opt/maven/latest

# get maven binary
wget https://dlcdn.apache.org/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.tar.gz -P /tmp

# un-tar
sudo tar xvf /tmp/apache-maven*.tar.gz --strip 1 -C /opt/maven/latest

# set environment variables
# environment variables
echo "" >> ~/.bashrc
echo 'export MAVEN_HOME=/opt/maven/latest' >> ~/.bashrc
echo 'export PATH=$MAVEN_HOME/bin:$PATH' >> ~/.bashrc
source .bashrc

# verify
mvn --version

# -------------------------------------------------- docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# post-install steps for non-sudo docker runs: https://docs.docker.com/engine/install/linux-postinstall/
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# verify
docker --version

# -------------------------------------------------- Further configuration
# configure the firewall to allow everything
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F
