# Convert user password to hash and save to temporary file
resource "null_resource" "save_hash_password" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      salt=$(openssl rand -base64 12)
      echo "${var.user.password}" | openssl passwd -6 -salt $salt -stdin > ${var.user.name}
    EOT
  }
}

# Check for the presence of a file with the user's password hash
locals {
  file_exists = fileexists(var.user.name) ? true : false
}

# Get the saved hash and put it in a variable
data "local_file" "get_hash_password" {
  filename = local.file_exists ? "${path.module}/${var.user.name}" : "terraform.tfstate"
  depends_on      = [null_resource.save_hash_password]
}

# User settings configuration template
data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    user_name     = var.user.name
    user_password = data.local_file.get_hash_password.content
    public_key    = openstack_compute_keypair_v2.keypair.public_key
  }
  depends_on      = [data.local_file.get_hash_password]
}

# Delete saved hash
resource "null_resource" "remove_hash_password" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      rm ${var.user.name}
    EOT
  }
  depends_on = [data.template_file.user_data]
}
