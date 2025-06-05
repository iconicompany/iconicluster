variable "MANUAL_CLUSTER_NODES" {
  description = "List of objects describing manually provisioned cluster nodes."
  type = list(object({
    hostname    = string
    external_ip = string
    internal_ip = string
    vm_name     = string
    vm_id       = string
  }))
  default     = []
}

variable "MANUAL_AGENT_NODES" {
  description = "List of objects describing manually provisioned agent nodes."
  type = list(object({
    hostname    = string
    external_ip = string
    internal_ip = string
    vm_name     = string
    vm_id       = string
  }))
  default     = []
}
