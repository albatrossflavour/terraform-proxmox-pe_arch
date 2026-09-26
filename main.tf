# Connection details come from the environment so no secret is written to
# disk: PROXMOX_VE_ENDPOINT, PROXMOX_VE_API_TOKEN and, for self-signed
# certificates, PROXMOX_VE_INSECURE=true.
provider "proxmox" {}

# The config path is explicit because hiera5 0.4.0 changed its default file
# name from hiera.yaml to hiera.yml.
provider "hiera5" {
  config = "${path.module}/hiera.yaml"
  scope = {
    architecture = var.architecture
    replica      = var.replica
    profile      = var.cluster_profile
  }
}

data "hiera5" "server_count" {
  key = "server_count"
}
data "hiera5" "database_count" {
  key = "database_count"
}
data "hiera5_bool" "has_compilers" {
  key = "has_compilers"
}
data "hiera5" "compiler_cores" {
  key = "compiler_cores"
}
data "hiera5" "compiler_memory" {
  key = "compiler_memory"
}
data "hiera5" "compiler_disk" {
  key = "compiler_disk_size"
}
data "hiera5" "primary_cores" {
  key = "primary_cores"
}
data "hiera5" "primary_memory" {
  key = "primary_memory"
}
data "hiera5" "primary_disk" {
  key = "primary_disk_size"
}
data "hiera5" "database_cores" {
  key = "database_cores"
}
data "hiera5" "database_memory" {
  key = "database_memory"
}
data "hiera5" "database_disk" {
  key = "database_disk_size"
}

# The template to clone, found by name. Exactly one must exist.
data "proxmox_virtual_environment_vms" "template" {
  count = var.destroy ? 0 : 1

  filter {
    name   = "name"
    values = [var.instance_image]
  }
  filter {
    name   = "template"
    values = ["true"]
  }

  lifecycle {
    postcondition {
      condition     = length(self.vms) == 1
      error_message = "Expected exactly one Proxmox template named ${var.instance_image}, found ${length(self.vms)}."
    }
  }
}

# A short random suffix keeps names unique when several deployments share a
# cluster, the same way the cloud modules do.
resource "random_id" "deployment" {
  byte_length = 3
}

locals {
  id    = random_id.deployment.hex
  nodes = [for n in split(",", var.region) : trimspace(n) if trimspace(n) != ""]

  template_id   = var.destroy ? null : data.proxmox_virtual_environment_vms.template[0].vms[0].vm_id
  template_node = var.destroy ? null : data.proxmox_virtual_environment_vms.template[0].vms[0].node_name

  compiler_count = data.hiera5_bool.has_compilers.value ? var.compiler_count : 0

  # Name each VM, with the domain appended when one is given. Proxmox passes
  # the VM name to cloud-init as the hostname, and DHCP registers it in DNS.
  suffix = var.domain_name == null ? "" : ".${var.domain_name}"

  ssh_keys = var.destroy ? [] : [trimspace(file(pathexpand(var.ssh_key)))]

  roles = {
    server = {
      count  = tonumber(data.hiera5.server_count.value)
      cores  = tonumber(data.hiera5.primary_cores.value)
      memory = tonumber(data.hiera5.primary_memory.value)
      disk   = tonumber(data.hiera5.primary_disk.value)
    }
    psql = {
      count  = tonumber(data.hiera5.database_count.value)
      cores  = tonumber(data.hiera5.database_cores.value)
      memory = tonumber(data.hiera5.database_memory.value)
      disk   = tonumber(data.hiera5.database_disk.value)
    }
    compiler = {
      count  = local.compiler_count
      cores  = tonumber(data.hiera5.compiler_cores.value)
      memory = tonumber(data.hiera5.compiler_memory.value)
      disk   = tonumber(data.hiera5.compiler_disk.value)
    }
    # Agents are for testing, so they get the smallest sizing
    node = {
      count  = var.node_count
      cores  = 2
      memory = 4096
      disk   = tonumber(data.hiera5.compiler_disk.value)
    }
  }

  # Name prefixes match the cloud modules
  prefix = {
    server   = "pe-server"
    psql     = "pe-psql"
    compiler = "pe-compiler"
    node     = "pe-node"
  }
}
