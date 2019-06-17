#for future terraform releases
#variable "servers" {
#  type = list(object({ name=string, location=string }))
#}
variable "server_type" {
  type = string
  description = "defines resources for provisioned server"
  default = "cx31-ceph"
}
variable "ssh_key_private" {
  type = string
  description = "Ssh private key to use for connection to a server. Export TF_VAR_ssh_key_private environment variable to define a value."
}
variable "ssh_key" {
  type = string
  description = "An id of public key of ssh key-pairs that will be used for connection to a server. Export TF_VAR_ssh_key environment variable to define a value."
}
variable "remote_user" {
  type = string
  description = "A user being used for a connection to a server. By default is root, unless redefined with user-data (cloud-init)."
  default = "root"
}
variable "ipa00_server_name" {
  type = string
  description = "IPA00 server name"
  default = "ipa00"
}
variable "ipa01_server_name" {
  type = string
  description = "IPA01 server name"
  default = "ipa01"
}
variable "ipa10_server_name" {
  type = string
  description = "IPA10 server name"
  default = "ipa10"
}
variable "ipa00_location" {
  type = string
  description = "IPA00 server location"
  default = "nbg1"
}
variable "ipa01_location" {
  type = string
  description = "IPA01 server location"
  default = "fsn1"
}
variable "ipa10_location" {
  type = string
  description = "IPA10 server location"
  default = "hel1"
}
variable "server_image" {
  type = string
  description = "An image being used for a server provisioning."
  default = "centos-7"
}
variable "domain" {
  type = string
  description = "A domain name for FreeIPA server. Export TF_VAR_domain environment variable to define."
}

provider "hcloud" {
}

#unfortunately it still does not work in 0.12
#data "hcloud_floating_ip" "ipa" {
#  for_each = var.servers
#  with_selector = "server==${each.name.value}"
#}

data "hcloud_floating_ip" "ipa00" {
  with_selector = "server==ipa00"
}

data "hcloud_floating_ip" "ipa10" {
  with_selector = "server==ipa10"
}

data "hcloud_floating_ip" "ipa01" {
  with_selector = "server==ipa01"
}

resource "hcloud_server" "ipa00" {
  name = "${var.ipa00_server_name}"
  server_type = "${var.server_type}"
  keep_disk = true
  backups = true
  image = "${var.server_image}"
  location = "${var.ipa00_location}"
  ssh_keys = [
    "${var.ssh_key}",
  ]
  provisioner "remote-exec" {
    inline = [
      "yum install python libselinux-python -y"
    ]
    connection {
      host = "${hcloud_server.ipa00.ipv4_address}"
      type = "ssh"
      user = "${var.remote_user}"
      private_key = "${file("${var.ssh_key_private}")}"
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i '${hcloud_server.ipa00.ipv4_address},' --ssh-common-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' --extra-vars 'server_name=${var.ipa00_server_name} domain_name=${var.domain} fixed_ip=${data.hcloud_floating_ip.ipa00.ip_address}' --user='${var.remote_user}' ipa_network.yml"
  }
}

resource "hcloud_server" "ipa01" {
  name = "${var.ipa01_server_name}"
  server_type = "${var.server_type}"
  keep_disk = true
  backups = true
  image = "${var.server_image}"
  location = "${var.ipa01_location}"
  ssh_keys = [
    "${var.ssh_key}",
  ]
  provisioner "remote-exec" {
    inline = [
      "yum install python libselinux-python -y"
    ]
    connection {
      host = "${hcloud_server.ipa01.ipv4_address}"
      type = "ssh"
      user = "${var.remote_user}"
      private_key = "${file("${var.ssh_key_private}")}"
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i '${hcloud_server.ipa01.ipv4_address},' --ssh-common-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' --extra-vars 'server_name=${var.ipa01_server_name} domain_name=${var.domain} fixed_ip=${data.hcloud_floating_ip.ipa01.ip_address}' --user='${var.remote_user}' ipa_network.yml"
  }
}

resource "hcloud_server" "ipa10" {
  name = "${var.ipa10_server_name}"
  server_type = "${var.server_type}"
  keep_disk = true
  backups = true
  image = "${var.server_image}"
  location = "${var.ipa10_location}"
  ssh_keys = [
    "${var.ssh_key}",
  ]
  provisioner "remote-exec" {
    inline = [
      "yum install python libselinux-python -y"
    ]
    connection {
      host = "${hcloud_server.ipa10.ipv4_address}"
      type = "ssh"
      user = "${var.remote_user}"
      private_key = "${file("${var.ssh_key_private}")}"
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i '${hcloud_server.ipa10.ipv4_address},' --ssh-common-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' --extra-vars 'server_name=${var.ipa10_server_name} domain_name=${var.domain} fixed_ip=${data.hcloud_floating_ip.ipa10.ip_address}' --user='${var.remote_user}' ipa_network.yml"
  }
}

resource "hcloud_floating_ip_assignment" "ipa00" {
  floating_ip_id = "${data.hcloud_floating_ip.ipa00.id}"
  server_id = "${hcloud_server.ipa00.id}"
}

resource "hcloud_floating_ip_assignment" "ipa01" {
  floating_ip_id = "${data.hcloud_floating_ip.ipa01.id}"
  server_id = "${hcloud_server.ipa01.id}"
}

resource "hcloud_floating_ip_assignment" "ipa10" {
  floating_ip_id = "${data.hcloud_floating_ip.ipa10.id}"
  server_id = "${hcloud_server.ipa10.id}"
}

#resource "null_resource" "cluster" {
#  # Changes to any instance of the cluster requires re-provisioning
#  triggers = {
#    cluster_instance_ids = "${join(",", hcloud_server[*].id)}"
#  }
#  provisioner "local-exec" {
#    command = "ansible-playbook  -i ${templatefile("${path.module}/inventory.yml")} --ssh-common-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' --extra-vars 'ipaadmin_password=${var.ipaadmin_password} ipadm_password=${var.ipadm_password} ipaserver_domain=${var.domain} ipaserver_realm=${upper(${var.domain})}' --user=${var.remote_user} --private-key=${var.ssh_key_private} ipa_deploy.yml"
#  }
#}

