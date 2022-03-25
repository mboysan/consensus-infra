# -------------------------------------------------- jdk-17
# prepare
sudo mkdir -p /opt/java/latest

# get zulu-jdk
wget https://cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-linux_x64.tar.gz -P /tmp

# un-tar
sudo tar xvf /tmp/zulu*.tar.gz --strip 1 -C /opt/java/latest

# environment variables
sudo touch /etc/profile.d/java.sh
sudo chmod +x /etc/profile.d/java.sh
sudo echo "export JAVA_HOME=/opt/java/latest" > /etc/profile.d/java.sh
sudo echo "export PATH=${JAVA_HOME}/bin:${PATH}" >> /etc/profile.d/java.sh
sudo source /etc/profile.d/java.sh

# -------------------------------------------------- maven

# get maven binary
wget https://dlcdn.apache.org/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.tar.gz -P /tmp

# extract it to /opt
sudo tar xf /tmp/apache-maven-*.tar.gz -C /opt

# set environment variables
sudo touch /etc/profile.d/maven.sh
