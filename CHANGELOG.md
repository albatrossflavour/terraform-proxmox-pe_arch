# Changelog

## Unreleased

First version: the Proxmox VE provider for pecdm.

- Clones VMs for the primary, PostgreSQL, compilers and agents from a named template, using `bpg/proxmox` 0.114.0
- Sizing from hiera data that mirrors the AWS module's instance types in cores and memory
- DHCP addressing, with pecdm connecting to the IPv4 address the guest agent reports
- `destroy` mode for pecdm's destroy plan, which skips the template lookup and SSH key read
