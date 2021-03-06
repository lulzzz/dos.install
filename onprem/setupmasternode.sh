#!/bin/bash
set -e
#
# This script is meant for quick & easy install via:
#   curl -sSL https://raw.githubusercontent.com/HealthCatalyst/dos.install/master/kubernetes/setupmaster.txt | bash
#
#

GITHUB_URL="https://raw.githubusercontent.com/HealthCatalyst/dos.install/master"
source <(curl -sSL "$GITHUB_URL/common/common.sh")

version="2018.03.28.01"
echo "---- setupmaster version $version ----"

u="$(whoami)"
echo "User name: $u"

# for calico network plugin
# sudo kubeadm init --kubernetes-version=v1.9.3 --pod-network-cidr=192.168.0.0/16

echo "--- running kubeadm init ---"
# for flannel network plugin
sudo kubeadm init --kubernetes-version=v1.9.3 --pod-network-cidr=10.244.0.0/16

# which CNI plugin to use: https://chrislovecnm.com/kubernetes/cni/choosing-a-cni-provider/

# for logs, sudo journalctl -xeu kubelet

echo "--- copying kube config to $HOME/.kube/config ---"
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# calico
# from https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/
# kubectl apply -f ${GITHUB_URL}/kubernetes/calico.yaml

# flannel
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
echo "--- enabling flannel network plugin ---"
kubectl apply -f ${GITHUB_URL}/kubernetes/cni/flannel.yaml

# enable master to run containers
# kubectl taint nodes --all node-role.kubernetes.io/master-

# kubectl create -f "$GITHUB_URL/azure/cafe-kube-dns.yml"
echo "--- nodes ---"
kubectl get nodes

echo "--- sleeping 10 secs to wait for pods ---"
sleep 10

echo "--- current pods ---"
kubectl get pods -n kube-system -o wide

echo "--- waiting for pods to run ---"
WaitForPodsInNamespace kube-system 5

echo "--- current pods ---"
kubectl get pods -n kube-system -o wide

if [[ ! -d "/mnt/data" ]]; then
    echo "--- creating /mnt/data ---"
    sudo mkdir -p /mnt/data
    sudo chown $(id -u):$(id -g) /mnt/data
    sudo chmod -R 777 /mnt/data
fi


# testing
# kubectl run nginx --image=nginx --port=80

# Register the Microsoft RedHat repository
echo "--- adding microsoft repo for powershell ---"
sudo yum-config-manager \
   --add-repo \
   https://packages.microsoft.com/config/rhel/7/prod.repo

# curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

# Install PowerShell
echo "--- installing powershell ---"
sudo yum install -y powershell

# Start PowerShell
# pwsh

echo "---- end setupmaster version $version ----"
