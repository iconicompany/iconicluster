locals {
  # This CLUSTER_DOMAIN is used for k3s --tls-san and potentially other services.
  # It represents the general cluster FQDN.
  # CLUSTER_DOMAIN = "${var.CLUSTER_NAME}.${local.CLUSTER_TLD}"
  CLUSTER_HOST = "${var.CLUSTER_DOMAIN}:6443"
  domain_parts = split(".", var.CLUSTER_DOMAIN)
  CLUSTER_TLD  = join(".", slice(local.domain_parts, length(local.domain_parts) - 2, length(local.domain_parts)))

  # Base FQDNs for nodes, passed to the module.
  # Node names will be like node01.kube01.example.com
  SERVER_NODES_BASE_FQDN = var.CLUSTER_DOMAIN
  # Agent names will be like agent01.kube01.example.com
  AGENT_NODES_BASE_FQDN = var.CLUSTER_DOMAIN
}

# Rustack module definition
module "nodes_rustack" {
  count  = var.RUSTACK_SERVERS_NUM > 0 ? 1 : 0
  source = "./modules/nodes/rustack"

  # Inputs for the rustack nodes module
  SERVERS_NUM = var.RUSTACK_SERVERS_NUM
  AGENTS_NUM  = var.RUSTACK_AGENTS_NUM

  SERVER_NODES = var.RUSTACK_SERVER_NODES
  NODES_CONFIG   = var.RUSTACK_AGENT_NODES
  USER_LOGIN             = var.USER_LOGIN

  CLUSTER_BASE_FQDN = local.SERVER_NODES_BASE_FQDN
  AGENT_BASE_FQDN   = local.AGENT_NODES_BASE_FQDN

  SERVER_NODES_POWER_ON = var.RUSTACK_CLUSTER_POWER
  AGENT_NODES_POWER_ON   = var.RUSTACK_AGENT_POWER # Assuming RUSTACK_AGENT_POWER variable exists for global agent power

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
    data.rustack_firewall_template.temporal.id,
    resource.rustack_firewall_template.nebula.id
  ]
  OS_TEMPLATE_ID        = data.rustack_template.ubuntu22.id   # Assuming these data sources are defined
  STORAGE_PROFILE_ID    = data.rustack_storage_profile.ssd.id # Assuming these data sources are defined
  STEPPATH              = var.STEPPATH
  SSH_USER_CA_FILE_PATH = var.SSH_USER_CA_FILE # Pass the path, module will use file()
  # ENABLE_FLOATING_IP can be set here if you want to control it from the root
}

# Manual module definition
# module "nodes_manual" {
#   count  = length(var.MANUAL_SERVER_NODES) > 0 ? 1 : 0
#   source = "./modules/nodes/manual"

#   SERVER_NODES = var.MANUAL_SERVER_NODES
#   AGENT_NODES   = var.MANUAL_AGENT_NODES 
# }

# Unified outputs for downstream modules like k3s
locals {
  rustack_output = length(module.nodes_rustack) > 0 ? module.nodes_rustack[0] : {
    SERVER_NODES = []
    AGENT_NODES   = []
  }

  # manual_output = length(module.nodes_manual) > 0 ? module.nodes_manual[0] : {
  #   SERVER_NODES = []
  #   AGENT_NODES   = []
  # }

  nodes_output = {
    SERVER_NODES = concat(local.rustack_output.SERVER_NODES, var.MANUAL_SERVER_NODES)
    AGENT_NODES   = concat(local.rustack_output.AGENT_NODES, var.MANUAL_AGENT_NODES)
  }
}
