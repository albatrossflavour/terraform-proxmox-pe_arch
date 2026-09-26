# terraform-proxmox-pe_arch

OpenTofu/Terraform module that builds the VMs for a Puppet Enterprise deployment on Proxmox VE. It is the Proxmox provider for [pecdm](https://github.com/albatrossflavour/puppetlabs-pecdm), alongside the Google, AWS and Azure `*_pe_arch` modules, and follows the same contract: pecdm writes the same variables, reads the same outputs and builds its inventory from the same resource names.

## What it builds

Only VMs, cloned from an existing template. Proxmox has no equivalent of the network, firewall and load balancer resources the cloud modules create, so this module assumes the network already exists.

| Role | Resource | Created when |
| ---- | -------- | ------------ |
| Primary (and replica) | `proxmox_virtual_environment_vm.server` | Always. Two with `replica = true` |
| PostgreSQL | `proxmox_virtual_environment_vm.psql` | `xlarge` only. Two with a replica |
| Compilers | `proxmox_virtual_environment_vm.compiler` | `large` and `xlarge`, `compiler_count` of them |
| Agents | `proxmox_virtual_environment_vm.node` | `node_count` of them |

Sizing (cores, memory, disk) comes from the hiera data in `data/`, keyed on `architecture`, `cluster_profile` and `replica`. The values are the AWS module's instance types converted to cores and memory, so a given architecture is the same size on every provider.

## What it assumes

- **A template to clone.** `instance_image` names a Proxmox VM template, for example one built by [goodmountain](https://github.com/albatrossflavour/goodmountain). Exactly one template may have that name. The module fails the plan if it finds none or several.
- **The template runs qemu-guest-agent and cloud-init.** The module waits for the guest agent to report an IPv4 address, and pecdm connects to that address.
- **DHCP that registers names in DNS.** VMs get their address by DHCP. Each VM is named `pe-<role>-<index>-<random id>`, with `domain_name` appended if you set it, and Proxmox passes that name to cloud-init as the hostname. Your DHCP server must register it so the PE nodes can resolve each other by name.
- **Shared storage for linked clones.** `full_clone = false` is faster but needs the template's disk to be reachable from every node, for example on Ceph.

## Connecting to Proxmox

The provider reads its connection details from the environment, so no secret is written to a tfvars file:

```bash
export PROXMOX_VE_ENDPOINT="https://pve.example.com:8006/"
export PROXMOX_VE_API_TOKEN="terraform@pve!pecdm=<secret>"
export PROXMOX_VE_INSECURE=true   # only for a self-signed certificate
```

## Inputs

pecdm writes the generic inputs itself. `region` is a comma-separated list of Proxmox nodes, and each role's VMs are spread across them in turn.

The Proxmox-specific inputs go through pecdm's `extra_terraform_vars`:

| Variable | Default | Purpose |
| -------- | ------- | ------- |
| `datastore_id` | `local-lvm` | Storage for disks and the cloud-init drive |
| `bridge` | `vmbr0` | Network bridge |
| `vlan_id` | `null` | VLAN tag, or untagged |
| `full_clone` | `true` | Full or linked clones |
| `pool_id` | `null` | Existing resource pool to put the VMs in |
| `cpu_type` | `host` | CPU type. EL10 needs x86-64-v3, which `host` provides on a capable node |
| `domain_name` | `null` | Domain appended to VM names |
| `tags` | `[]` | Extra Proxmox tags |

The inputs that only mean something on a cloud (`lb_ip_mode`, `disable_lb`, `firewall_allow`, `subnet`, `subnet_project`) are accepted and have no effect. Windows agents are not supported.

## Outputs

- `console`: the primary's IP address.
- `pool`: the first compiler's name, or the primary's when there are no compilers. Proxmox has no load balancer, so this matches what the cloud modules return with theirs disabled. Put a DNS round robin or your own load balancer in front of the compilers if you need one.

## Versions

- OpenTofu or Terraform `>= 1.5`
- `bpg/proxmox` 0.114.0
- `chriskuchin/hiera5` 0.5.4, with its config path set explicitly because 0.4.0 changed the default file name
- `hashicorp/random` 3.9.1
