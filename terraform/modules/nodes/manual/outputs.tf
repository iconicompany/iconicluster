output "cluster_hostnames" {
  description = "List of hostnames for cluster VMs."
  value       = var.MANUAL_CLUSTER_HOSTNAMES
}

output "cluster_external_ips" {
  description = "List of floating IPs for cluster VMs."
  value       = var.MANUAL_CLUSTER_EXTERNAL_IPS
}

output "cluster_internal_ips" {
  description = "List of internal IPs for cluster VM ports."
  value       = var.MANUAL_CLUSTER_INTERNAL_IPS
}

output "cluster_vm_names" {
  description = "List of cluster VM names."
  value       = var.MANUAL_CLUSTER_VM_NAMES
}

output "cluster_vm_ids" {
  description = "List of cluster VM IDs."
  value       = var.MANUAL_CLUSTER_VM_IDS
}

output "agent_hostnames" {
  description = "List of hostnames for agent VMs."
  value       = var.MANUAL_AGENT_HOSTNAMES
}

output "agent_external_ips" {
  description = "List of floating IPs for agent VMs."
  value       = var.MANUAL_AGENT_EXTERNAL_IPS
}

output "agent_internal_ips" {
  description = "List of internal IPs for agent VM ports."
  value       = var.MANUAL_AGENT_INTERNAL_IPS
}

output "agent_vm_names" {
  description = "List of agent VM names."
  value       = var.MANUAL_AGENT_VM_NAMES
}

output "agent_vm_ids" {
  description = "List of agent VM IDs."
  value       = var.MANUAL_AGENT_VM_IDS
}
