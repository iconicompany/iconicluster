output "CLUSTER_NODES" {
  description = "List of objects describing manually provisioned cluster nodes."
  value       = var.MANUAL_CLUSTER_NODES
}

output "AGENT_NODES" {
  description = "List of objects describing manually provisioned agent nodes."
  value       = var.MANUAL_AGENT_NODES
}
