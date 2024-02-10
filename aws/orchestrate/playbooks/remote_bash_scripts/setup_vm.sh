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

# -------------------------------------------------- R
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
sudo apt-get update
sudo apt-get install -y r-base

# -------------------------------------------------- etcd

ETCD_VER=v3.5.8
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GITHUB_URL}
INSTALL_DIR=~/etcd

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf ${INSTALL_DIR} && mkdir -p ${INSTALL_DIR}

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C ${INSTALL_DIR} --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

${INSTALL_DIR}/etcd --version

# -------------------------------------------------- Further configuration
# configure the firewall to allow everything
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F
