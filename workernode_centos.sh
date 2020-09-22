#!/bin/bash
sudo yum -y update
sudo yum -y install wget nc bind-utils unzip yum-utils device-mapper-persistent-data lvm2 perl
sudo swapoff -a
sudo perl -pi -e 's/\/root\/swap/#\/root\/swap/' /etc/fstab
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce
sudo sed -i '/^ExecStart/ s/$/ --exec-opt native.cgroupdriver=systemd/' /usr/lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl start docker
cat << EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo setenforce 0
sudo perl -pi -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet
sudo systemctl start kubelet
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=8285/udp # Flannel
sudo firewall-cmd --permanent --add-port=8472/udp # Flannel
sudo firewall-cmd --permanent --add-port=30000-32767/tcp
sudo firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --reload
sudo systemctl restart firewalld
sudo firewall-cmd --list-ports
