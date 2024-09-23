variable "linode_api_token" {
  description = "Token de API de Linode"
}

variable "workers" {
  description = "List of workers with their labels and IP addresses"
  type = map(object({
    ipam_address = string
    label        = string
    tags         = list(string)
  }))
}

#variable "ipcp5" {
  description = "ip contolplane 4"
#}
#variable "ipcp4" {
  description = "ip contolplane 4"
#}
#variable "ipcp3" {
  description = "ip contolplane 5"
#}
#variable "ipha" {
  description = "ip contolplane 6"
#}
