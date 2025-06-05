# Cluster Nodes

resource "terraform_data" "cluster_hostname" {
  count = var.SERVERS_NUM
  input = "node0${count.index + 1}.${var.CLUSTER_BASE_FQDN}"
}

resource "rustack_port" "cluster_port" {
  count      = var.SERVERS_NUM
  vdc_id     = var.VDC_ID
  ip_address = "${var.CLUSTER_IP_NETWORK_PREFIX}${count.index + var.CLUSTER_IP_START_OFFSET}"
  network_id = var.NETWORK_ID
  firewall_templates = var.FIREWALL_TEMPLATE_IDS
}

data "template_file" "cluster_cloud_config" {
  count    = var.SERVERS_NUM
  template = file("${path.module}/cluster-cloud-config.tpl") # Assumes cluster-cloud-config.tpl is in the module directory
  vars = {
    USER_LOGIN  = var.USER_LOGIN
    STEPPATH    = var.STEPPATH
    HOSTNAME    = resource.terraform_data.cluster_hostname[count.index].output
    SSH_USER_CA = file(var.SSH_USER_CA_FILE_PATH) # file() reads the content
  }
}

resource "rustack_vm" "cluster_vm" {
  count  = var.SERVERS_NUM
  vdc_id = var.VDC_ID
  name   = resource.terraform_data.cluster_hostname[count.index].output
  cpu    = var.CLUSTER_SERVER_CONFIGS[count.index].cpu
  ram    = var.CLUSTER_SERVER_CONFIGS[count.index].ram
  power  = var.CLUSTER_NODES_POWER_ON && var.CLUSTER_SERVER_CONFIGS[count.index].power

  template_id = var.OS_TEMPLATE_ID
  user_data   = data.template_file.cluster_cloud_config[count.index].rendered

  lifecycle {
    ignore_changes = [user_data, template_id]
  }

  system_disk {
    size               = var.CLUSTER_SERVER_CONFIGS[count.index].disk
    storage_profile_id = var.STORAGE_PROFILE_ID
  }

  ports = [resource.rustack_port.cluster_port[count.index].id]

  floating = var.ENABLE_FLOATING_IP
}

# Agent Nodes

resource "terraform_data" "agent_hostname" {
  count = var.AGENTS_NUM
  input = "agent0${count.index + 1}.${var.AGENT_BASE_FQDN}"
}

resource "rustack_port" "agent_port" {
  count      = var.AGENTS_NUM
  vdc_id     = var.VDC_ID
  ip_address = "${var.AGENT_IP_NETWORK_PREFIX}${count.index + var.AGENT_IP_START_OFFSET}"
  network_id = var.NETWORK_ID
  firewall_templates = var.FIREWALL_TEMPLATE_IDS # Assuming same firewall templates for agents, adjust if needed
}

data "template_file" "agent_cloud_config" {
  count    = var.AGENTS_NUM
  template = file("${path.module}/agent-cloud-config.tpl") # Assumes agent-cloud-config.tpl is in the module directory
  vars = {
    USER_LOGIN  = var.USER_LOGIN
    STEPPATH    = var.STEPPATH
    HOSTNAME    = resource.terraform_data.agent_hostname[count.index].output
    SSH_USER_CA = file(var.SSH_USER_CA_FILE_PATH)
  }
}

resource "rustack_vm" "agent_vm" {
  count  = var.AGENTS_NUM
  vdc_id = var.VDC_ID
  name   = resource.terraform_data.agent_hostname[count.index].output
  cpu    = var.AGENT_SERVER_CONFIGS[count.index].cpu
  ram    = var.AGENT_SERVER_CONFIGS[count.index].ram
  power  = var.AGENT_NODES_POWER_ON && var.AGENT_SERVER_CONFIGS[count.index].power

  template_id = var.OS_TEMPLATE_ID
  user_data   = data.template_file.agent_cloud_config[count.index].rendered

  lifecycle {
    ignore_changes = [user_data, template_id]
  }

  system_disk {
    size               = var.AGENT_SERVER_CONFIGS[count.index].disk
    storage_profile_id = var.STORAGE_PROFILE_ID
  }

  ports = [resource.rustack_port.agent_port[count.index].id]

  floating = var.ENABLE_FLOATING_IP
}
