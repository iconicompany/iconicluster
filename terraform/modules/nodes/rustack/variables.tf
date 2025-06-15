variable "SERVERS_NUM" {
  description = "Number of control plane nodes."
  type        = number
  default     = 1
}

variable "AGENTS_NUM" {
  description = "Number of agent nodes."
  type        = number
  default     = 0
}

variable "CLUSTER_SERVER_CONFIGS" {
  description = "Configuration for each cluster server (cpu, ram, disk, power)."
  type = list(object({
    cpu   = number
    ram   = number
    disk  = number
    power = bool
  }))
}

variable "AGENT_SERVER_CONFIGS" {
  description = "Configuration for each agent server (cpu, ram, disk, power)."
  type = list(object({
    cpu   = number
    ram   = number
    disk  = number
    power = bool
  }))
}

variable "USER_LOGIN" {
  description = "User's login for SSH access."
  type        = string
}

variable "CLUSTER_BASE_FQDN" {
  description = "Base FQDN for cluster nodes, e.g., kube01.example.com. Node names will be node0X.<CLUSTER_BASE_FQDN>."
  type        = string
}

variable "AGENT_BASE_FQDN" {
  description = "Base FQDN for agent nodes, e.g., agents.example.com. Node names will be agent0X.<AGENT_BASE_FQDN>."
  type        = string
}

variable "SERVER_NODES_POWER_ON" {
  description = "Global power switch for cluster nodes."
  type        = bool
  default     = true
}

variable "AGENT_NODES_POWER_ON" {
  description = "Global power switch for agent nodes."
  type        = bool
  default     = true
}

variable "VDC_ID" {
  description = "Rustack VDC ID."
  type        = string
}

variable "NETWORK_ID" {
  description = "Rustack Network ID."
  type        = string
}

variable "FIREWALL_TEMPLATE_IDS" {
  description = "List of Rustack Firewall Template IDs for node ports."
  type        = list(string)
}

variable "OS_TEMPLATE_ID" {
  description = "Rustack OS Template ID for VMs."
  type        = string
}

variable "STORAGE_PROFILE_ID" {
  description = "Rustack Storage Profile ID for VM disks."
  type        = string
}

variable "STEPPATH" {
  description = "StepCA config dir path on nodes."
  type        = string
}

variable "SSH_USER_CA_FILE_PATH" {
  description = "Path to the SSH User CA public key file (will be read by file() function)."
  type        = string
}

variable "CLUSTER_IP_NETWORK_PREFIX" {
  description = "Network prefix for cluster node IPs, e.g., 10.0.1."
  type        = string
  default     = "10.0.1."
}

variable "CLUSTER_IP_START_OFFSET" {
  description = "Starting offset for cluster node IPs, e.g., 101 for 10.0.1.101."
  type        = number
  default     = 101
}

variable "AGENT_IP_NETWORK_PREFIX" {
  description = "Network prefix for agent node IPs, e.g., 10.0.2."
  type        = string
  default     = "10.0.2."
}

variable "AGENT_IP_START_OFFSET" {
  description = "Starting offset for agent node IPs, e.g., 1 for 10.0.2.1."
  type        = number
  default     = 1
}

variable "ENABLE_FLOATING_IP" {
  description = "Enable floating IP for nodes."
  type        = bool
  default     = true
}
