resource "linode_stackscript" "node" {
  label = "node"
  description = "Configure a node for k8s"
  script = <<EOF
#! /bin/bash -xe

exec > >(tee /var/log/userdata.log|logger -t userdata -s 2>/dev/console) 2>&1

export IP="$(ip addr show eth0 | grep -oP 'inet \K[\d.]+')"

export N="$(ip addr show eth0 | grep -oP 'inet \K[\d.]+' | awk -F'.' '{print $NF}')"

hostnamectl set-hostname worker$N

echo "
[Match]
Name=eth0

[Network]
DHCP=no
DNS=9.9.9.9 8.8.8.8
Domains=members.linode.com
IPv6PrivacyExtensions=false

Gateway=172.16.1.1
Address=$IP/24" > /etc/systemd/network/05-eth0.network

sudo systemctl restart systemd-networkd

echo "10.3.101.51 k8scp" >> /etc/hosts

apt-get update
apt-get install -y vim
apt install curl apt-transport-https vim git wget \
software-properties-common lsb-release ca-certificates -y
swapoff -a
modprobe overlay
modprobe br_netfilter

echo "net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1" > /etc/sysctl.d/kubernetes.conf

sudo sysctl --system

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install containerd.io -y
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
systemctl restart containerd

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

curl -s \
https://packages.cloud.google.com/apt/doc/apt-key.gpg \
| apt-key add -

apt-get update

apt-get install -y kubeadm=1.28.1-00 kubelet=1.28.1-00 kubectl=1.28.1-00
apt-mark hold kubelet kubeadm kubectl

kubeadm join --discovery-token cq1xjm.76cv01c9kvs3dua7 --discovery-token-ca-cert-hash sha256:e4f723afc0fa78d0158199ee2d96dcadc17ce8a979d11800ad911eddc445ed14 k8scp:6443

EOF
  images = ["linode/ubuntu20.04"]
  rev_note = "initial version"
}