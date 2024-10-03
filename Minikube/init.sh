#!/bin/bash

type minikube &>/dev/null
if [ $? -ne 0 ]; then
  growpart /dev/nvme0n1 4 
  lvextend -l +80%FREE /dev/mapper/RootVG-varVol ; xfs_growfs /var
  lvextend -l +100%FREE /dev/mapper/RootVG-homeVol ; xfs_growfs /home
  df -h > /tmp/space.txt
  dnf install https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm -y
fi

type docker &>/dev/null
if [ $? -ne 0 ]; then
  dnf install docker -y
fi

sysctl fs.protected_regular=0
curl -L -o /bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x /bin/kubectl


echo "Running the following command - minikube start --force"
minikube start --force

