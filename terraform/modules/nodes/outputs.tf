output "cluster_hostnames" {
  description = "List of hostnames for cluster VMs."
  value       = [for ch in terraform_data.cluster_hostname : ch.output]
}

output "cluster_floating_ips" {
  description = "List of floating IPs for cluster VMs."
  value       = [for vm in rustack_vm.cluster_vm : vm.floating_ip]
}

output "cluster_internal_ips" {
  description = "List of internal IPs for cluster VM ports."
  value       = [for port in rustack_port.cluster_port : port.ip_address]
}

output "cluster_vm_names" {
  description = "List of cluster VM names."
  value       = [for vm in rustack_vm.cluster_vm : vm.name]
}
output "cluster_vm_ids" {
  description = "List of cluster VM IDs."
  value       = [for vm in rustack_vm.cluster_vm : vm.id]
}

output "agent_hostnames" {
  description = "List of hostnames for agent VMs."
  value       = [for ch in terraform_data.agent_hostname : ch.output]
}

output "agent_floating_ips" {
  description = "List of floating IPs for agent VMs."
  value       = [for vm in rustack_vm.agent_vm : vm.floating_ip]
}

output "agent_internal_ips" {
  description = "List of internal IPs for agent VM ports."
  value       = [for port in rustack_port.agent_port : port.ip_address]
}

output "agent_vm_names" {
  description = "List of agent VM names."
  value       = [for vm in rustack_vm.agent_vm : vm.name]
}
