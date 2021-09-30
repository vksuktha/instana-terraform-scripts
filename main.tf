data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

data "ibm_is_vpc" "vpc" {
  name           = var.vpc_name
}

data "ibm_is_subnet" "subnet" {
  name                     = var.subnet_name
}

resource "ibm_is_ssh_key" "ssh-key" {
  name           = "${var.name}-key"
  public_key     = file(var.ssh_instana_public_key_file)
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group" "security_group" {
  vpc = data.ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
  name = "${var.name}-sg"
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-ssh" {
//  group     = ibm_is_vpc.vpc.security_group[0].group_id
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "sg-rule-http-port" {
//  group     = ibm_is_vpc.vpc.security_group[0].group_id
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "sg-rule-https-port" {
//  group     = ibm_is_vpc.vpc.security_group[0].group_id
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "sg-rule-eum-port-1" {
//  group     = ibm_is_vpc.vpc.security_group[0].group_id
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 86
    port_max = 86
  }
}

resource "ibm_is_security_group_rule" "sg-rule-eum-port-2" {
//  group     = ibm_is_vpc.vpc.security_group[0].group_id
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 446
    port_max = 446
  }
}

resource "ibm_is_security_group_rule" "sg-rule-acceptor" {
//  group     = ibm_is_vpc.vpc.security_group[0].group_id
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 1444
    port_max = 1444
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-icmp" {
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  icmp {
    type = 8
  }
}

resource "ibm_is_security_group_rule" "sg-rule-outbound" {
  group     = ibm_is_security_group.security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 1
    port_max = 65535
  }
}

resource "ibm_is_security_group_rule" "sg-rule-outbound-all" {
  group     = ibm_is_security_group.security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Hosts must have TCP/UDP/ICMP Layer 3 connectivity for all ports across hosts.
# You cannot block access to certain ports that might block communication across hosts.
resource "ibm_is_security_group_rule" "sg-rule-inbound-from-the-group" {
  group     = ibm_is_security_group.security_group.id
//  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "inbound"
//  remote    = ibm_is_vpc.vpc.security_group[0].group_id
  remote    = ibm_is_security_group.security_group.id
}

resource "ibm_is_security_group_rule" "sg-rule-outbound-to-the-group" {
  group     = ibm_is_security_group.security_group.id
//  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "outbound"
//  remote    = ibm_is_vpc.vpc.security_group[0].group_id
  remote    = ibm_is_security_group.security_group.id
}


data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-20-04-minimal-amd64-2"
}

resource "ibm_is_instance" "is_instance" {
  name    = var.name
  image   = data.ibm_is_image.ubuntu.id
  profile = "bx2-16x64"

  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet            = data.ibm_is_subnet.subnet.id
    security_groups   = [ibm_is_security_group.security_group.id]
    allow_ip_spoofing = true
  }

  vpc  = data.ibm_is_vpc.vpc.id
  zone = var.zone
  keys = [ibm_is_ssh_key.ssh-key.id]

  timeouts {
    # From experience, this sometimes takes longer than 30m, which is the
    # default.
    create = "60m"
    update = "60m"
    delete = "60m"
  }

}

resource "ibm_is_floating_ip" "fip" {
  name              = var.name
  target            = ibm_is_instance.is_instance.primary_network_interface[0].id
  resource_group    = data.ibm_resource_group.group.id

}

resource "null_resource" "instana" {
  
  connection {
    type     = "ssh"
    user     = "root"
    host     =  ibm_is_floating_ip.fip.address
    private_key = file(var.ssh_instana_private_key_file)
  }
  provisioner "file" {
    source      = "files"
    destination = "/instana/"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sed -i 's/HOSTNAME/${ibm_is_floating_ip.fip.address}/g' /instana/settings.hcl",
      "sed -i 's/AGENT_KEY/${var.agent_key}/g' /instana/settings.hcl",
      "sed -i 's/SALES_ID/${var.sales_id}/g' /instana/settings.hcl",
      "chmod +x /instana/instana.sh",
      "/instana/instana.sh",
      "openssl req -x509 -newkey rsa:2048 -keyout /instana/cert/tls.key -out /instana/cert/tls.crt -days 365 -nodes -subj \"/CN=${ibm_is_floating_ip.fip.address}\" ",
      "instana init -f /instana/settings.hcl -y --force > /instana/instana_init_output.txt",
      "tail -n 3 /instana/instana_init_output.txt > /instana/instana_credentials.txt",
      "instana license download",
      "instana license import",
      "instana license verify",
      "echo 'The crdentials to access Instana are as follows:' ",
      "cat /instana/instana_credentials.txt",
      "echo 'The crdentials to access Instana are stored in the VM and available at /instana/instana_credentials.txt' "
    ]
  }

}