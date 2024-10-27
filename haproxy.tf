resource "linode_stackscript" "haproxy" {
  label = "haproxy"
  description = "Configure HA-Proxy"
  script = <<EOF
#! /bin/bash -xe

exec > >(tee /var/log/userdata.log|logger -t userdata -s 2>/dev/console) 2>&1

export IP="$(ip addr show eth0 | grep -oP 'inet \K[\d.]+')"

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

sudo apt-get update ; sudo apt-get install -y haproxy vim 

sed -i 's/mode\thttp/mode\ttcp/g' /etc/haproxy/haproxy.cfg
sed -i 's/option\thttplog/option\ttcplog/g' /etc/haproxy/haproxy.cfg

echo "
frontend httpnodes
bind *:80
stats uri /proxystats
default_backend k8sHttp

backend k8sHttp
balance roundrobin
server k3sm 172.16.2.101:31843 check #<-- Edit these with your IP addresses, port, and hostname
server k3sm2 172.16.2.102:31843 check
server k3sm3 172.16.2.103:31843 check
server worker101 172.16.1.101:31843 check
server worker102 172.16.1.102:31843 check

frontend HTTPSNodes
bind *:443
stats uri /proxystats
default_backend k8sHttps

backend k8sHttps
balance roundrobin
server cp 172.16.2.101:30257 check #<-- Edit these with your IP addresses, port, and hostname
server cp2 172.16.2.102:30257 check
server cp3 172.16.2.103:30257 check
server worker101 172.16.1.101:30257 check
server worker102 172.16.1.102:30257 check
#server cp3 172.30.0.53:6443 check
#server cp4 172.16.0.51:6443 check #<-- Comment out until ready
#server cp5 172.16.0.52:6443
#server cp6 172.16.0.53:6443
listen stats
bind :9999
mode http
stats enable
stats hide-version
stats uri /stats" >> /etc/haproxy/haproxy.cfg

sudo systemctl restart haproxy.service
sudo systemctl status haproxy.service
EOF
  images = ["linode/ubuntu20.04"]
  rev_note = "initial version"
}