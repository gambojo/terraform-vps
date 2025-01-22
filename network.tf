# get external network
data "openstack_networking_network_v2" "external_network" {
  name = var.external_network_name
}

# network
resource "openstack_networking_network_v2" "network" {
  name           = "${var.network.net_name}_network"
  admin_state_up = "true"
  external       = "false"
  shared         = "false"
}

# subnet
resource "openstack_networking_subnet_v2" "subnet" {
  name            = "${var.network.net_name}_subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = var.network.cidr_block
  gateway_ip      = var.network.gateway_ip
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = var.network.dns_nameservers
  depends_on      = [openstack_networking_network_v2.network]
}

# router
resource "openstack_networking_router_v2" "router" {
  name                = "${var.network.net_name}_router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_network.id
  depends_on          = [openstack_networking_subnet_v2.subnet]
}

# router interface
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id  = openstack_networking_router_v2.router.id
  subnet_id  = openstack_networking_subnet_v2.subnet.id
  depends_on = [openstack_networking_router_v2.router]
}

# fip
resource "openstack_networking_floatingip_v2" "fip" {
  count      = length(var.instances)
  pool       = var.external_network_name
  depends_on = [openstack_networking_router_interface_v2.router_interface]
}

# port
resource "openstack_networking_port_v2" "port" {
  count          = length(var.instances)
  name           = var.instances[count.index].name
  network_id     = openstack_networking_network_v2.network.id
  admin_state_up = "true"
  depends_on     = [openstack_networking_subnet_v2.subnet]
}

# fip associate
resource "openstack_networking_floatingip_associate_v2" "fip_associate" {
  count       = length(var.instances)
  floating_ip = openstack_networking_floatingip_v2.fip[count.index].address
  port_id     = openstack_networking_port_v2.port[count.index].id
  depends_on  = [openstack_networking_floatingip_v2.fip]
}

# port secgroup associate
resource "openstack_networking_port_secgroup_associate_v2" "port_secgroup_associate" {
  count   = length(var.instances)
  port_id = openstack_networking_port_v2.port[count.index].id
  enforce = "true"
  security_group_ids = [
    openstack_networking_secgroup_v2.secgroup.id,
  ]
  depends_on = [openstack_networking_secgroup_rule_v2.secgroup_rules]
}
