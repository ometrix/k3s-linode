resource "linode_stackscript" "node" {
  label = "node"
  description = "Configure a node for k8s"
  script = <<EOF
#! /bin/bash -xe

exec > >(tee /var/log/userdata.log|logger -t userdata -s 2>/dev/console) 2>&1

export IP="$(ip addr show eth0 | grep -oP 'inet \K[\d.]+')"

export N="$(ip addr show eth0 | grep -oP 'inet \K[\d.]+' | awk -F'.' '{print $NF}')"

hostnamectl set-hostname k3sm$N

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

echo "172.16.2.101 k3sm" >> /etc/hosts

apt-get update
apt-get install -y vim
apt install curl apt-transport-https vim git wget \
software-properties-common lsb-release ca-certificates -y
swapoff -a

curl -sfL https://get.k3s.io | K3S_URL=https://k3sm:6443 K3S_KUBECONFIG_MODE=644 K3S_TOKEN="K107713504f50039599bb071d33175f9a74b2f38c4f4d123a79c05bb76e8cc95d25::server:6b222492093cd174bf075fc09f9861ed" INSTALL_K3S_EXEC='server' sh -s -

EOF
  images = ["linode/ubuntu20.04"]
  rev_note = "2.0"
}