#!/bin/bash
sudo yum -y update
sudo yum -y install wget nc bind-utils unzip yum-utils device-mapper-persistent-data lvm2
sudo swapoff -a
sudo sed -i 's/^[^#]*swap/#&/' /etc/fstab
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
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet
sudo systemctl start kubelet
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
sudo firewall-cmd --permanent --add-port=6443/tcp # Kubernetes API server
sudo firewall-cmd --permanent --add-port=2379-2380/tcp # etcd server client API
sudo firewall-cmd --permanent --add-port=10250/tcp # Kubelet API
sudo firewall-cmd --permanent --add-port=10251/tcp # kube-scheduler
sudo firewall-cmd --permanent --add-port=10252/tcp # kube-controller-manager
sudo firewall-cmd --permanent --add-port=8285/udp # Flannel
sudo firewall-cmd --permanent --add-port=8472/udp # Flannel
sudo firewall-cmd --add-masquerade --permanent
# only if you want NodePorts exposed on control plane IP as well
# firewall-cmd --permanent --add-port=30000-32767/tcp
sudo firewall-cmd --reload
sudo systemctl restart firewalld
sudo firewall-cmd --list-ports

# Master node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
