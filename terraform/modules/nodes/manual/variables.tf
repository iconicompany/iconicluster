variable "SERVERS_NUM" {
  description = "Number of manually provisioned control plane nodes."
  type        = number
  default     = 0
}

variable "AGENTS_NUM" {
  description = "Number of manually provisioned agent nodes."
  type        = number
  default     = 0
}

variable "MANUAL_CLUSTER_HOSTNAMES" {
  description = "List of hostnames for manually provisioned cluster VMs."
  type        = list(string)
  default     = []
}

variable "MANUAL_CLUSTER_EXTERNAL_IPS" {
  description = "List of external/floating IPs for manually provisioned cluster VMs."
  type        = list(string)
  default     = []
}

variable "MANUAL_CLUSTER_INTERNAL_IPS" {
  description = "List of internal IPs for manually provisioned cluster VMs."
  type        = list(string)
  default     = []
}

variable "MANUAL_CLUSTER_VM_NAMES" {
  description = "List of VM names for manually provisioned cluster VMs (can be same as hostnames)."
  type        = list(string)
  default     = []
}

variable "MANUAL_CLUSTER_VM_IDS" {
  description = "List of VM IDs for manually provisioned cluster VMs (can be arbitrary strings if not applicable)."
  type        = list(string)
  default     = []
}

variable "MANUAL_AGENT_HOSTNAMES" {
  description = "List of hostnames for manually provisioned agent VMs."
  type        = list(string)
  default     = []
}

variable "MANUAL_AGENT_EXTERNAL_IPS" {
  description = "List of external/floating IPs for manually provisioned agent VMs."
  type        = list(string)
  default     = []
}

variable "MANUAL_AGENT_INTERNAL_IPS" {
  description = "List of internal IPs for manually provisioned agent VMs."
  type        = list(string)
  default     = []
}

variable "MANUAL_AGENT_VM_NAMES" {
  description = "List of VM names for manually provisioned agent VMs (can be same as hostnames)."
  type        = list(string)
  default     = []
}

variable "MANUAL_AGENT_VM_IDS" {
  description = "List of VM IDs for manually provisioned agent VMs (can be arbitrary strings if not applicable)."
  type        = list(string)
  default     = []
}
