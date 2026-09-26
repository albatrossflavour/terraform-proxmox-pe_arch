# Output data used by Bolt to do further work, doing this allows for a clean and
# abstracted interface between cloud provider implementations

output "console" {
  value       = try(proxmox_virtual_environment_vm.server[0].ipv4_addresses[1][0], null)
  description = "IP address of the primary server, where the PE console runs"
}

# Proxmox has no load balancer, so the pool is the first compiler, or the
# primary when the architecture has no compilers. This matches what the cloud
# modules return when their load balancer is disabled.
output "pool" {
  value       = try(local.compiler_count > 0 ? proxmox_virtual_environment_vm.compiler[0].name : proxmox_virtual_environment_vm.server[0].name, null)
  description = "Name of the first compiler, or of the primary when there are no compilers"
}
