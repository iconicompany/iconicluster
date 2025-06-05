output "cluster_hostnames" {
  description = "List of hostnames for cluster VMs."
  value       = [for node in var.MANUAL_CLUSTER_NODES : node.hostname]
}

output "cluster_external_ips" {
  description = "List of floating IPs for cluster VMs."
  value       = [for node in var.MANUAL_CLUSTER_NODES : node.external_ip]
}

output "cluster_internal_ips" {
  description = "List of internal IPs for cluster VM ports."
  value       = [for node in var.MANUAL_CLUSTER_NODES : node.internal_ip]
}

output "cluster_vm_names" {
  description = "List of cluster VM names."
  value       = [for node in var.MANUAL_CLUSTER_NODES : node.vm_name]
}

output "cluster_vm_ids" {
  description = "List of cluster VM IDs."
  value       = [for node in var.MANUAL_CLUSTER_NODES : node.vm_id]
}

output "agent_hostnames" {
  description = "List of hostnames for agent VMs."
  value       = [for node in var.MANUAL_AGENT_NODES : node.hostname]
}

output "agent_external_ips" {
  description = "List of floating IPs for agent VMs."
  value       = [for node in var.MANUAL_AGENT_NODES : node.external_ip]
}

output "agent_internal_ips" {
  description = "List of internal IPs for agent VM ports."
  value       = [for node in var.MANUAL_AGENT_NODES : node.internal_ip]
}

output "agent_vm_names" {
  description = "List of agent VM names."
  value       = [for node in var.MANUAL_AGENT_NODES : node.vm_name]
}

output "agent_vm_ids" {
  description = "List of agent VM IDs."
  value       = [for node in var.MANUAL_AGENT_NODES : node.vm_id]
}
