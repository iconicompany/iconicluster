locals {
  AGENT_NAME   = "kube01.${var.CLUSTER_TLD}"
  AGENT_HOST   = "kube01.${var.CLUSTER_TLD}:6443"
}

# Создание порта сервера (шаг 9)
# Указываем ВЦОД в котором порт будет создан, сеть к которой он должен быть присоединён и IP-адрес, а также шаблон брандмауэра

resource "rustack_port" "agent_port" {
  count      = var.SERVERS_NUM
  vdc_id     = data.rustack_vdc.iconicvdc.id
  ip_address = "10.0.1.${count.index + 111}"
  network_id = data.rustack_network.iconicnet.id
  firewall_templates = [
    data.rustack_firewall_template.default.id,
    data.rustack_firewall_template.web.id,
    data.rustack_firewall_template.ssh.id,
    data.rustack_firewall_template.icmp.id,
    #data.rustack_firewall_template.kubeapi.id,
    #data.rustack_firewall_template.postgresql.id,
    #data.rustack_firewall_template.mongodb.id,
    #data.rustack_firewall_template.redis.id,
    #data.rustack_firewall_template.temporal.id
  ]
}

#resource "time_static" "agent_update" {
#  count = var.SERVERS_NUM
#  triggers = {
#    agent_id = resource.rustack_port.agent_port[count.index].id
#  }
#}

data "template_file" "agent-cloud-config" {
  count    = var.SERVERS_NUM
  template = file("cluster-cloud-config.tpl")
  vars = {
    USER_LOGIN = var.USER_LOGIN
    #public_key = file(var.public_key)
    STEPPATH    = var.STEPPATH
    HOSTNAME    = resource.terraform_data.agentname[count.index].output
    SSH_USER_CA = file(var.SSH_USER_CA_FILE)
  }
}

# Создание сервера.
# Задаём его имя и конфигурацию. Выбираем шаблон ОС по его id, который получили на шаге 7. Ссылаемся на скрипт инициализации. Указываем размер и тип основного диска.
# Выбираем порт сервера созданный на шаге 9
# Указываем, что необходимо получить публичный адрес.
resource "rustack_vm" "agent" {
  count  = var.AGENTS_NUM
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = resource.terraform_data.agentname[count.index].output
  cpu    = var.AGENT_SERVER[count.index].cpu
  ram    = var.AGENT_SERVER[count.index].ram
  power  = var.AGENT_POWER && var.AGENT_SERVER[count.index].power

  template_id = data.rustack_template.ubuntu22.id
  user_data   = data.template_file.agent-cloud-config[count.index].rendered

  lifecycle {
    ignore_changes = [user_data,template_id]
  }
  system_disk {
    size               = var.AGENT_SERVER[count.index].disk
    storage_profile_id = data.rustack_storage_profile.ssd.id
  }

  ports = [resource.rustack_port.agent_port[count.index].id]

  floating = true
}

resource "terraform_data" "agentname" {
  count = var.AGENTS_NUM
  input = "agent0${count.index+1}.${local.AGENT_NAME}"
}
