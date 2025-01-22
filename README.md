# terraform-vps

## Variables
### General description of variables
| Name | Description | Type |
|---|---|---|
| instances | Instance parameters | list(object) |
| secgroup_rules | Security group rules | list(object) |
| network | Network parameters | object |
| user | User parameters | object |

### Description of each variable
#### instances
```hcl
instances = [
    {
        name        = string # required     <any>            Default( terraform-instance )
        image       = string # optional     <any>            Default( ubuntu-22.04.4 )
        flavor      = string # optional     <any>            Default( 2-4-10 )
        volume_size = number # optional     <any>            Default( 10 )
    }
]
```

#### secgroup_rules
```hcl
secgroup_rules = [
    {
        port_range = {
            min = number,   # required      <1-65535>        Default( 22 )
            max = number    # required      <1-65535>        Default( 22 )
        }
        protocol  = string  # required      <TCP/UDP/"">     Default( "" )
        ethertype = string  # optional      <IPv4/IPv6>      Default( IPv4 )
        direction = string  # optional      <ingress/egress> Default( ingress )
    }
]
```

#### network
```hcl
network = {
    net_name        = string # required     <any>            Default( terraform )
    extnet_name     = string # required     <any>            Default( external )
    cidr_block      = string # optional     <0.0.0.0/0>      Default( 192.168.0.0/24 )
    dns_nameservers = list   # optional     <["0.0.0.0"]>    Default( ["8.8.8.8"] )
}
```

#### user
```hcl
user = {
    name      = string       # required     <any>            Default( terraform )
    password  = string       # required     <any>            Default( terraform123 )
}
```

## Usage
### Preparation
- Create a file called `terraform.tfvars`
- Populate the file with variables to override defaults. Example:
```hcl
instances = [
    { name = "example-instance-1" },
    { name = "example-instance-2" },
    { name = "example-instance-3" }
]

secgroup_rules = [
    {
    port_range = { min = 22, max = 22 },
    protocol   = ""
    },
    {
    port_range = { min = 80, max = 80 },
    protocol   = ""
    }
]

network = {
    net_name    = "network-1",
    extnet_name = "ext-net-1"
}

user = {
    name     = "user-1",
    password = "P@s$w0rd321"
}
```
- In the [`provider.tf`](provider.tf) file, define the credentials for connecting to openstack. Example:
```hcl
provider "openstack" {
    insecure          = true
    auth_url          = https://openstack.domain.ru:5000/v3/
    user_name         = os-user
    password          = os-password
    user_domain_name  = default
    region            = region
}
```
- Init the terraform workspace
```hcl
terraform init
```
