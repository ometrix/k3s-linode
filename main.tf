terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.5.2"
    }
  }
}

# Configuración del proveedor Linode
provider "linode" {
  token = var.linode_api_token
}

# Creación de una máquina virtual
resource "linode_instance" "haproxy" {
  region    = "us-southeast"
  type      = "g6-nanode-1"
  label     = "haproxy"
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = [ "haproxy" ]
  swap_size = 1

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = "172.16.0.2/24"
  }

  stackscript_id = linode_stackscript.haproxy.id
}

resource "linode_instance" "cp2" {
  region    = "us-southeast"
  type      = "g6-standard-2"
  label     = "cp2"
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = [ "cp2" ]
  swap_size = 1

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = "172.16.0.3/24"
  }

  stackscript_id = linode_stackscript.node.id

}

resource "linode_instance" "worker2" {
  region    = "us-southeast"
  type      = "g6-standard-2"
  label     = "worker2"
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = [ "worker2" ]
  swap_size = 1

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = "172.16.0.4/24"
  }

  stackscript_id = linode_stackscript.node.id
}