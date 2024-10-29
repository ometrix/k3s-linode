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

resource "linode_instance" "worker" {
  for_each = var.workers

  region    = "us-mia"
  type      = "g6-standard-1"
  label     = each.value.label
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = each.value.tags
  swap_size = 2000

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = each.value.ipam_address
  }

  stackscript_id = linode_stackscript.node.id
  }

### HA old config not need it right now ###
resource "linode_instance" "haproxy" {
  region    = "us-mia"
  type      = "g6-nanode-1"
  label     = "haproxy"
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = [ "haproxy" ]
  swap_size = 500

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = var.ipha
  }

  stackscript_id = linode_stackscript.haproxy.id

}