resource "linode_sshkey" "sec" {
  label = "sec"
  ssh_key = chomp(file("./secret0mar.pub"))
}