# setupkubernetes quickly installs kubernetes cluster on centos/redhat or ubuntu
Instructions

sudo yum -y install git or sudo apt-get -y install git

mkdir repos; cd repos

git clone https://github.com/joelckwong/setupkubernetes.git

cd setupkubernetes

./runfirst.sh

./master_centos.sh or ./workernode_centos.sh if it's centos/redhat

./master_ubuntu.sh or ./workernode_ubuntu.sh if it's ubuntu

run sudo kubeadm join .... on the worker nodes

run "kubectl get pods --all-namespaces" and "kubectl get nodes" on master

Install Istio on master

curl -L https://istio.io/downloadIstio | sh -

cd istio-1.7.2

export PATH=$PWD/bin:$PATH

cd install/kubernetes

perl -pi -e 's/type: LoadBalancer/type: NodePort/' istio-demo.yaml

kubectl apply -f istio-demo.yaml

kubectl -n istio-system get pods

kubectl -n istio-system get service

cd ../..

kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)

kubectl get pods
