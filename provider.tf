terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  insecure = true
}

#provider "openstack" {
#    insecure          = true
#    auth_url          = https://os-1.cp.dev.cldx.ru:5000/v3/
#    user_name         = user
#    password          = password
#    user_domain_name  = default
#    region            = region
#}
