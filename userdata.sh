#!/bin/bash
apt update
apt install docker.io -y
usermod -aG docker ubuntu
apt install zip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
snap install kubectl --classic
