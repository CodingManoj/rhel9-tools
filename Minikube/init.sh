#!/bin/bash

type minikube &>/dev/null
if [ $? -ne 0 ]; then

  growpart /dev/nvme0n1 4
  sleep 10
  lvextend -l +80%FREE /dev/mapper/RootVG-varVol ; sleep 10 ; xfs_growfs /var
  sleep 10 
  lvextend -l +100%FREE /dev/mapper/RootVG-homeVol; sleep 10 ; xfs_growfs /home
  
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

