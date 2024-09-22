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

  region    = "us-southeast"
  type      = "g6-standard-2"
  label     = each.value.label
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = each.value.tags
  swap_size = 1

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = each.value.ipam_address
  }

  stackscript_id = linode_stackscript.node.id
}

### HA old config not need it right now ###
#resource "linode_instance" "haproxy" {
  region    = "us-southeast"
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

#}
### Worker old config ###
#resource "linode_instance" "worker101" {
  region    = "us-southeast"
  type      = "g6-standard-2"
  label     = "worker101"
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = [ "worker101" ]
  swap_size = 1

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = var.ipcp4
  }

  stackscript_id = linode_stackscript.node.id

#}
### Worker old config ###
#resource "linode_instance" "worker102" {
  region    = "us-southeast"
  type      = "g6-standard-2"
  label     = "worker102"
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = [ "worker102" ]
  swap_size = 1

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = var.ipcp3
  }

  stackscript_id = linode_stackscript.node.id
#}
### Worker old config ###
#resource "linode_instance" "worker103" {
  region    = "us-southeast"
  type      = "g6-standard-2"
  label     = "worker103"
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = [ "worker103" ]
  swap_size = 1

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = var.ipcp5
  }

  stackscript_id = linode_stackscript.node.id
#}

#old way setup
#resource "linode_instance" "cp6" {
  region    = "us-southeast"
  type      = "g6-standard-2"
  label     = "cp6"
  image     = "linode/ubuntu20.04"
  authorized_keys = [linode_sshkey.sec.ssh_key]
  root_pass = "dad23,ad;kfa321/"

  tags = [ "cp6" ]
  swap_size = 1

  interface {
    purpose = "vlan"
    label = "pfsense"
    ipam_address = var.ipcp6
  }

  stackscript_id = linode_stackscript.node.id
#}