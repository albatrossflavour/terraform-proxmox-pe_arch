# One resource per role. pecdm builds its inventory by matching
# proxmox_virtual_environment_vm.<role> in state, so the names are part of the
# contract. The four blocks are identical apart from the role and the node
# offset, which staggers each role's starting node so a small cluster doesn't
# put the primary, database and first compiler on the same node.

resource "proxmox_virtual_environment_vm" "server" {
  count = var.destroy ? 0 : local.roles.server.count

  name      = "${local.prefix.server}-${count.index}-${local.id}${local.suffix}"
  node_name = local.nodes[(0 + count.index) % length(local.nodes)]
  pool_id   = var.pool_id
  tags      = sort(distinct(concat(["pecdm", lower(var.project), "server"], var.tags)))
  on_boot   = true
  started   = true

  clone {
    vm_id     = local.template_id
    node_name = local.template_node
    full      = var.full_clone
  }

  # Waiting for an IPv4 address means ipv4_addresses is in state by the time
  # pecdm builds its inventory from it
  agent {
    enabled = true
    timeout = "15m"
    wait_for_ip {
      ipv4 = true
    }
  }

  cpu {
    cores = local.roles.server.cores
    type  = var.cpu_type
  }

  memory {
    dedicated = local.roles.server.memory
  }

  disk {
    interface    = "scsi0"
    datastore_id = var.datastore_id
    size         = local.roles.server.disk
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  network_device {
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = var.user
      keys     = local.ssh_keys
    }
  }
}

resource "proxmox_virtual_environment_vm" "psql" {
  count = var.destroy ? 0 : local.roles.psql.count

  name      = "${local.prefix.psql}-${count.index}-${local.id}${local.suffix}"
  node_name = local.nodes[(1 + count.index) % length(local.nodes)]
  pool_id   = var.pool_id
  tags      = sort(distinct(concat(["pecdm", lower(var.project), "psql"], var.tags)))
  on_boot   = true
  started   = true

  clone {
    vm_id     = local.template_id
    node_name = local.template_node
    full      = var.full_clone
  }

  # Waiting for an IPv4 address means ipv4_addresses is in state by the time
  # pecdm builds its inventory from it
  agent {
    enabled = true
    timeout = "15m"
    wait_for_ip {
      ipv4 = true
    }
  }

  cpu {
    cores = local.roles.psql.cores
    type  = var.cpu_type
  }

  memory {
    dedicated = local.roles.psql.memory
  }

  disk {
    interface    = "scsi0"
    datastore_id = var.datastore_id
    size         = local.roles.psql.disk
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  network_device {
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = var.user
      keys     = local.ssh_keys
    }
  }
}

resource "proxmox_virtual_environment_vm" "compiler" {
  count = var.destroy ? 0 : local.roles.compiler.count

  name      = "${local.prefix.compiler}-${count.index}-${local.id}${local.suffix}"
  node_name = local.nodes[(2 + count.index) % length(local.nodes)]
  pool_id   = var.pool_id
  tags      = sort(distinct(concat(["pecdm", lower(var.project), "compiler"], var.tags)))
  on_boot   = true
  started   = true

  clone {
    vm_id     = local.template_id
    node_name = local.template_node
    full      = var.full_clone
  }

  # Waiting for an IPv4 address means ipv4_addresses is in state by the time
  # pecdm builds its inventory from it
  agent {
    enabled = true
    timeout = "15m"
    wait_for_ip {
      ipv4 = true
    }
  }

  cpu {
    cores = local.roles.compiler.cores
    type  = var.cpu_type
  }

  memory {
    dedicated = local.roles.compiler.memory
  }

  disk {
    interface    = "scsi0"
    datastore_id = var.datastore_id
    size         = local.roles.compiler.disk
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  network_device {
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = var.user
      keys     = local.ssh_keys
    }
  }
}

resource "proxmox_virtual_environment_vm" "node" {
  count = var.destroy ? 0 : local.roles.node.count

  name      = "${local.prefix.node}-${count.index}-${local.id}${local.suffix}"
  node_name = local.nodes[(0 + count.index) % length(local.nodes)]
  pool_id   = var.pool_id
  tags      = sort(distinct(concat(["pecdm", lower(var.project), "node"], var.tags)))
  on_boot   = true
  started   = true

  clone {
    vm_id     = local.template_id
    node_name = local.template_node
    full      = var.full_clone
  }

  # Waiting for an IPv4 address means ipv4_addresses is in state by the time
  # pecdm builds its inventory from it
  agent {
    enabled = true
    timeout = "15m"
    wait_for_ip {
      ipv4 = true
    }
  }

  cpu {
    cores = local.roles.node.cores
    type  = var.cpu_type
  }

  memory {
    dedicated = local.roles.node.memory
  }

  disk {
    interface    = "scsi0"
    datastore_id = var.datastore_id
    size         = local.roles.node.disk
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  network_device {
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = var.user
      keys     = local.ssh_keys
    }
  }
}
