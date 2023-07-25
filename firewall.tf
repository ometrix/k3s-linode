# Creación de un firewall
resource "linode_firewall" "worker_firewall" {
  label = "worker_firewall"

  inbound {
    label    = "allow-all-private"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "1-65535"
    ipv4     = ["172.16.0.0/24","10.3.100.2/32","172.30.0.0/16"]
  }
  inbound {
    label    = "allow-all-private"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "1-65535"
    ipv4     = ["172.16.0.0/24","10.3.100.2/32","172.30.0.0/16"]
  }
  inbound {
    label    = "allow-all-private"
    action   = "ACCEPT"
    protocol = "ICMP"
    ipv4     = ["172.16.0.0/24","10.3.100.2/32","172.30.0.0/16"]
  }

  inbound_policy = "DROP"

  outbound_policy = "ACCEPT"

  linodes = [linode_instance.worker2.id, linode_instance.haproxy.id, linode_instance.cp2.id]
}