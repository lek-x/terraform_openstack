# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.login
  tenant_name = var.tenant
  password    = var.pass
  auth_url    = var.auth
  region      = var.reg
}

### Define SSH key
resource "openstack_compute_keypair_v2" "mezkp" {
  name       = "my-keypair"
  public_key =  var.ssh_key
}

### Define flavor size
data "openstack_compute_flavor_v2" "small" {
  name = "cpu_2_ram_2g"
}


#######################################__Network_block__#####################################
### Define network
resource "openstack_networking_network_v2" "network_1" {
  name           = "network_1"
  admin_state_up = "true"
}


### Define subnet 
resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet_1"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  
  allocation_pool {
	start = "192.168.0.5" 
	end =  "192.168.0.50"
  
  }
  
  ip_version = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

### Define FW rules
resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name        = "secgroup_1"
  description = "my_sec_group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"	 
  }
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  
}
}

### Deinfe floating IP (need to know)
resource "openstack_networking_floatingip_associate_v2" "fip_1" {
  floating_ip = "10.61.6.21"
  port_id     = openstack_networking_port_v2.port_1.id
}

### Define router's port  for subnet 
resource "openstack_networking_port_v2" "port_1" {
  name               = "port_1"
  network_id         = openstack_networking_network_v2.network_1.id
  admin_state_up     = "true"
  security_group_ids = [openstack_compute_secgroup_v2.secgroup_1.id]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.0.10"
  }
}

### Import router (need to know)
data "openstack_networking_router_v2" "router" {
  name = "router_146749"
}

### Attach network to router 
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = data.openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}


#####################################___End Network Block___################################

#### Define Image ID (need to know)

resource "openstack_blockstorage_volume_v2" "myvol" {
  name = "myvol"
  size = 10
  image_id = "9a918b7c-1cd0-449e-94e1-fb06bc840026"
}


### Creating VM with all previous things with was defined
resource "openstack_compute_instance_v2" "instance_1" {
  name            = "rmvm"
  flavor_id       = data.openstack_compute_flavor_v2.small.flavor_id
  key_pair        = openstack_compute_keypair_v2.mezkp.name
  security_groups = ["secgroup_1"]
  
  block_device {
    uuid                  = openstack_blockstorage_volume_v2.myvol.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
  
  metadata = {
    this = "that"
  }

  network {
    port = openstack_networking_port_v2.port_1.id
  }
}


#output "pub_ip" {
#  value = openstack_networking_floatingip_v2.fip_1.address
#}