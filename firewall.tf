# Creación de un firewall
resource "linode_firewall" "worker_firewall" {
  label = "worker_firewall"

  inbound {
    label    = "allow-all-private"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "1-65535"
    ipv4     = ["172.16.1.0/24","10.3.200.0/32","172.16.2.0/24"]
  }
  inbound {
    label    = "allow-all-private"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "1-65535"
    ipv4     = ["172.16.1.0/24","10.3.200.0/32","172.16.2.0/24"]
  }
  inbound {
    label    = "allow-all-private"
    action   = "ACCEPT"
    protocol = "ICMP"
    ipv4     = ["172.16.1.0/24","10.3.200.0/32","172.16.2.0/24"]
  }

  inbound_policy = "DROP"

  outbound_policy = "ACCEPT"

  #linodes = [linode_instance.haproxy.id] 
  linodes = [linode_instance.worker101.id, linode_instance.worker102.id, linode_instance.worker103.id] 
}