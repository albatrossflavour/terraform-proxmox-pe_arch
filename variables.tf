# Inputs pecdm writes for every provider. Some have no Proxmox equivalent; they
# are declared so pecdm's tfvars apply cleanly, and noted where they do nothing.

variable "project" {
  description = "Name of the deployment, used to tag every VM"
  type        = string
  default     = "pecdm"
}

variable "user" {
  description = "User cloud-init creates on each VM for SSH access"
  type        = string
  default     = "pecdm"
}

variable "ssh_key" {
  description = "Location on disk of the SSH public key to install for var.user"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "region" {
  description = "Comma-separated Proxmox node names to place VMs on, for example \"ankh,morpork,stolat\". Each role's VMs are spread across them in turn"
  type        = string
}

variable "compiler_count" {
  description = "Number of compilers, used by the large and xlarge architectures"
  type        = number
  default     = 1
}

variable "node_count" {
  description = "Number of agent nodes to deploy for testing"
  type        = number
  default     = 0
}

variable "instance_image" {
  description = "Name of the Proxmox VM template to clone, for example a goodmountain template such as template-Rocky-9"
  type        = string
  default     = "template-Rocky-9"
}

variable "architecture" {
  description = "PE architecture: standard, large or xlarge"
  type        = string
  default     = "large"
}

variable "cluster_profile" {
  description = "Sizing profile: development, production or user"
  type        = string
  default     = "development"
}

variable "replica" {
  description = "Deploy a replica primary (and replica database on xlarge)"
  type        = bool
  default     = false
}

variable "lb_ip_mode" {
  description = "No effect on Proxmox, which has no load balancer"
  type        = string
  default     = "private"
}

variable "disable_lb" {
  description = "No effect on Proxmox, which has no load balancer"
  type        = bool
  default     = true
}

variable "firewall_allow" {
  description = "No effect on Proxmox. The module does not manage the Proxmox firewall"
  type        = list(any)
  default     = []
}

variable "subnet" {
  description = "No effect on Proxmox. Use var.bridge and var.vlan_id"
  type        = any
  default     = null
}

variable "subnet_project" {
  description = "No effect on Proxmox"
  type        = string
  default     = null
}

variable "windows_node_count" {
  description = "Windows agents are not supported on Proxmox. Must be 0 or unset"
  type        = number
  default     = 0

  validation {
    condition     = var.windows_node_count == null || var.windows_node_count == 0
    error_message = "Windows agent nodes are not supported by the Proxmox provider."
  }
}

variable "windows_user" {
  description = "Unused: Windows agents are not supported on Proxmox"
  type        = string
  default     = null
}

variable "windows_password" {
  description = "Unused: Windows agents are not supported on Proxmox"
  type        = string
  default     = null
  sensitive   = true
}

variable "windows_instance_image" {
  description = "Unused: Windows agents are not supported on Proxmox"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "Domain appended to VM names. Leave unset if your DHCP server supplies the domain when it registers names"
  type        = string
  default     = null
}

variable "destroy" {
  description = "Set by pecdm's destroy plan. Skips the template lookup and SSH key read, which destroying doesn't need"
  type        = bool
  default     = false
}

# Proxmox-specific inputs. Pass these to pecdm with extra_terraform_vars.

variable "datastore_id" {
  description = "Storage for VM disks and the cloud-init drive"
  type        = string
  default     = "local-lvm"
}

variable "bridge" {
  description = "Network bridge for the VMs' single interface"
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN tag for the VMs' interface, or null for untagged"
  type        = number
  default     = null
}

variable "full_clone" {
  description = "Full clones are independent of the template. Linked clones are faster but need the template's storage to be reachable from every node, for example Ceph"
  type        = bool
  default     = true
}

variable "pool_id" {
  description = "Existing Proxmox resource pool to put the VMs in, or null for none"
  type        = string
  default     = null
}

variable "cpu_type" {
  description = "CPU type presented to the VMs. host exposes the node's real CPU flags, which EL10 needs for x86-64-v3"
  type        = string
  default     = "host"
}

variable "tags" {
  description = "Extra Proxmox tags to apply to every VM"
  type        = list(string)
  default     = []
}
