yum install git java-1.8.0-openjdk tree -y
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
tar -xvzf apache-maven-3.9.9-bin.tar.gz
sudo mv apache-maven-3.9.9 /opt/maven
export M2_HOME=/opt/maven/apache-maven-3.9.9
export PATH=$M2_HOME/bin:$PATH
source ~/.bashrc

yum install docker -ysystemctl start docker
sudo chmod 666 /var/run/docker.sock
systemctl restart docker
systemctl status docker
mvn -v
