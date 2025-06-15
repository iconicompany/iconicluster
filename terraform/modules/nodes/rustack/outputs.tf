output "SERVER_NODES" {
  description = "List of objects describing provisioned cluster nodes."
  value = [
    for i in range(var.SERVERS_NUM) : {
      hostname    = terraform_data.cluster_hostname[i].output
      external_ip = rustack_vm.cluster_vm[i].floating_ip
      internal_ip = rustack_port.cluster_port[i].ip_address
      vm_name     = rustack_vm.cluster_vm[i].name
      vm_id       = rustack_vm.cluster_vm[i].id
    }
  ]
}

output "AGENT_NODES" {
  description = "List of objects describing provisioned agent nodes."
  value = [
    for i in range(var.AGENTS_NUM) : {
      hostname    = terraform_data.agent_hostname[i].output
      external_ip = rustack_vm.agent_vm[i].floating_ip
      internal_ip = rustack_port.agent_port[i].ip_address
      vm_name     = rustack_vm.agent_vm[i].name
      vm_id       = rustack_vm.agent_vm[i].id
    }
  ]
}
