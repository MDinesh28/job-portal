yum install docker -y
yum install git java-1.8.0-openjdk maven tree -y
systemctl start docker
sudo chmod 666 /var/run/docker.sock
systemctl restart docker
systemctl status docker
