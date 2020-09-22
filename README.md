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

istioctl install --set profile=demo

kubectl label namespace default istio-injection=enabled

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

kubectl get services

kubectl get pods

kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -s productpage:9080/productpage | grep -o "<title>.*</title>"
