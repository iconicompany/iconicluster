locals {
  # This CLUSTER_NAME is used for k3s --tls-san and potentially other services.
  # It represents the general cluster FQDN.
  CLUSTER_NAME = "${var.CLUSTER_NAME}.${var.CLUSTER_TLD}"
  CLUSTER_HOST = "${local.CLUSTER_NAME}:6443"

  # Base FQDNs for nodes, passed to the module.
  # Node names will be like node01.kube01.example.com
  cluster_nodes_base_fqdn = local.CLUSTER_NAME
  # Agent names will be like agent01.agents.example.com
  agent_nodes_base_fqdn = "agents.${var.CLUSTER_TLD}" # Adjust if your agent naming is different
}

# Rustack module definition
module "nodes_rustack" {
  count  = var.PROVISON_METHOD == "rustack" ? 1 : 0
  source = "./modules/nodes/rustack"

  # Inputs for the rustack nodes module
  SERVERS_NUM = var.SERVERS_NUM
  AGENTS_NUM  = var.AGENTS_NUM

  CLUSTER_SERVER_CONFIGS = var.CLUSTER_SERVER
  AGENT_SERVER_CONFIGS   = var.AGENT_SERVER
  USER_LOGIN             = var.USER_LOGIN

  CLUSTER_BASE_FQDN = local.cluster_nodes_base_fqdn
  AGENT_BASE_FQDN   = local.agent_nodes_base_fqdn

  CLUSTER_NODES_POWER_ON = var.CLUSTER_POWER
  AGENT_NODES_POWER_ON   = var.AGENT_POWER # Assuming AGENT_POWER variable exists for global agent power

  VDC_ID     = data.rustack_vdc.iconicvdc.id     # Assuming these data sources are defined in your root module
  NETWORK_ID = data.rustack_network.iconicnet.id # Assuming these data sources are defined in your root module
  FIREWALL_TEMPLATE_IDS = [                      # Pass the list of firewall template IDs
    data.rustack_firewall_template.default.id,
    data.rustack_firewall_template.web.id,
    data.rustack_firewall_template.ssh.id,
    data.rustack_firewall_template.icmp.id,
    data.rustack_firewall_template.kubeapi.id,
    data.rustack_firewall_template.postgresql.id,
    data.rustack_firewall_template.mongodb.id,
    data.rustack_firewall_template.redis.id,
    data.rustack_firewall_template.temporal.id
  ]
  OS_TEMPLATE_ID        = data.rustack_template.ubuntu22.id   # Assuming these data sources are defined
  STORAGE_PROFILE_ID    = data.rustack_storage_profile.ssd.id # Assuming these data sources are defined
  STEPPATH              = var.STEPPATH
  SSH_USER_CA_FILE_PATH = var.SSH_USER_CA_FILE # Pass the path, module will use file()
  # ENABLE_FLOATING_IP can be set here if you want to control it from the root
}

# Manual module definition
module "nodes_manual" {
  count  = var.PROVISON_METHOD == "manual" ? 1 : 0
  source = "./modules/nodes/manual"

  CLUSTER_NODES = var.MANUAL_CLUSTER_NODES
  AGENT_NODES   = var.MANUAL_AGENT_NODES 
  }

# Unified outputs for downstream modules like k3s
locals {
  nodes_output_raw = var.PROVISON_METHOD == "rustack" ? (length(module.nodes_rustack) > 0 ? module.nodes_rustack[0] : null) : (length(module.nodes_manual) > 0 ? module.nodes_manual[0] : null)

  default_node_outputs = {
    CLUSTER_NODES = []
    AGENT_NODES   = []
  }

  nodes_output = local.nodes_output_raw != null ? local.nodes_output_raw : local.default_node_outputs
}
