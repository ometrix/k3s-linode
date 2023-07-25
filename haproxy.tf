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

Gateway=172.16.0.1
Address=$IP/24" > /etc/systemd/network/05-eth0.network

sudo systemctl restart systemd-networkd

sudo apt-get update ; sudo apt-get install -y haproxy vim

sed -i 's/mode\thttp/mode\ttcp/g' /etc/haproxy/haproxy.cfg
sed -i 's/option\thttplog/option\ttcplog/g' /etc/haproxy/haproxy.cfg

echo "frontend proxynode
bind *:80
bind *:6443
stats uri /proxystats
default_backend k8sServers

backend k8sServers
balance roundrobin
server cp 172.30.0.51:6443 check #<-- Edit these with your IP addresses, port, and hostname
# server secondcp 172.16.0.3:6443 check #<-- Comment out until ready
# server thirdcp 10.128.0.66:6443 check #<-- Comment out until ready
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