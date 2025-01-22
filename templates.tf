# make hash of user password and save
resource "null_resource" "save_hash_password" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      salt=$(openssl rand -base64 12)
      echo "${var.user.password}" | openssl passwd -6 -salt $salt -stdin > ${var.user.name}
    EOT
  }
}

# check file exists
locals {
  file_exists = fileexists(var.user.name) ? true : false
}

# get saved hash
data "local_file" "get_hash_password" {
  filename = local.file_exists ? "${path.module}/${var.user.name}" : "terraform.tfstate"
  depends_on      = [null_resource.save_hash_password]
}

# cloud config template file
data "template_file" "cloud_config" {
  template = file("${path.module}/cloud-config.tpl")

  vars = {
    user_name     = var.user.name
    user_password = data.local_file.get_hash_password.content
    public_key    = openstack_compute_keypair_v2.keypair.public_key
  }
  depends_on      = [data.local_file.get_hash_password]
}

# remove saved hash
resource "null_resource" "remove_hash_password" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      rm ${var.user.name}
    EOT
  }
  depends_on = [data.template_file.cloud_config]
}
