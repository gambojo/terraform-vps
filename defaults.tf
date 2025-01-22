# instances
variable "instances" {
  type = list(object({
    name        = string
    image       = optional(string)
    flavor      = optional(string)
    volume_size = optional(string)
  }))
  default = [
    {
      name        = "terraform-instance-1"
      image       = "cxpaas-v0.4.13-1"
      flavor      = "2-4-0"
      volume_size = 10
    },
    {
      name        = "terraform-instance-2"
      image       = "cxpaas-v0.4.13-1"
      flavor      = "2-4-0"
      volume_size = 10
    },
    {
      name        = "terraform-instance-3"
      image       = "cxpaas-v0.4.13-1"
      flavor      = "2-4-0"
      volume_size = 10
    }
  ]
}

# secgroup roles
variable "secgroup_rules" {
  type = list(object({
    port_range = object({
      min = number
      max = number
    })
    protocol  = string
    ethertype = optional(string)
    direction = optional(string)
  }))
  default = [
    {
      port_range = {
        min = 0,
        max = 0
      }
      ethertype = "IPv4"
      protocol  = ""
      direction = "ingress"
    },
    {
      port_range = {
        min = 0,
        max = 0
      }
      ethertype = "IPv6"
      protocol  = ""
      direction = "ingress"
    }
  ]
}

# network
variable "external_network_name" {
  type    = string
  default = "external"
}

variable "network" {
  type = any
  default = {
    net_name   = "terraform",
    cidr_block = "192.168.10.0/24",
    gateway_ip = "192.168.10.1",
    dns_nameservers = [
      "8.8.8.8",
      "10.26.90.17"
    ]
  }
}

# user
variable "user" {
  type = map(string)
  default = {
    name     = "terraform",
    password = "terraform123"
  }
}
