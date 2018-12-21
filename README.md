# setupkubernetes quickly installs kubernetes cluster on centos/redhat or ubuntu
Instructions

sudo yum -y install git or sudo apt-get -y install git

mkdir repos; cd repos

git clone https://github.com/joelckwong/setupkubernetes.git

cd setupkubernetes

./runfirst.sh

./master_centos.sh or ./slave_centos.sh if it's centos/redhat

./master_ubuntu.sh or ./slave_ubuntu.sh if it's ubuntu

run sudo kubeadm join .... on the slave nodes

run kubectl get nodes on master
