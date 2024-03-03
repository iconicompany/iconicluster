# Создание порта сервера (шаг 9)
# Указываем ВЦОД в котором порт будет создан, сеть к которой он должен быть присоединён и IP-адрес, а также шаблон брандмауэра

resource "rustack_port" "cluster_port" {
  count      = var.SERVERS_NUM
  vdc_id     = data.rustack_vdc.iconicvdc.id
  #ip_address = "10.0.1.${count.index + 10}"
  network_id = data.rustack_network.iconicnet.id
  firewall_templates = [
    data.rustack_firewall_template.allow_default.id,
    data.rustack_firewall_template.allow_web.id,
    data.rustack_firewall_template.allow_ssh.id,
    data.rustack_firewall_template.allow_icmp.id,
    data.rustack_firewall_template.allow_kubeapi.id,
    data.rustack_firewall_template.allow_postgresql.id
  ]
}

#resource "time_static" "cluster_update" {
#  count = var.SERVERS_NUM
#  triggers = {
#    cluster_id = resource.rustack_port.cluster_port[count.index].id
#  }
#}

data "template_file" "cluster-cloud-config" {
  count    = var.SERVERS_NUM
  template = file("cluster-cloud-config.tpl")
  vars = {
    USER_LOGIN = var.USER_LOGIN
    #public_key = file(var.public_key)
    STEPPATH    = var.STEPPATH
    HOSTNAME    = resource.terraform_data.hostname[count.index].output
    SSH_USER_CA = file(var.SSH_USER_CA_FILE)
  }
}

# Создание сервера.
# Задаём его имя и конфигурацию. Выбираем шаблон ОС по его id, который получили на шаге 7. Ссылаемся на скрипт инициализации. Указываем размер и тип основного диска.
# Выбираем порт сервера созданный на шаге 9
# Указываем, что необходимо получить публичный адрес.
resource "rustack_vm" "cluster" {
  count  = var.SERVERS_NUM
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = resource.terraform_data.hostname[count.index].output
  cpu    = var.CLUSTER_SERVER[count.index].cpu
  ram    = var.CLUSTER_SERVER[count.index].ram
  power  = var.CLUSTER_POWER && var.CLUSTER_SERVER[count.index].power

  template_id = data.rustack_template.ubuntu22.id
  user_data   = data.template_file.cluster-cloud-config[count.index].rendered

  lifecycle {
    ignore_changes = [user_data]
  }
  system_disk {
    size               = var.CLUSTER_SERVER[count.index].disk
    storage_profile_id = data.rustack_storage_profile.ssd.id
  }

  ports = [resource.rustack_port.cluster_port[count.index].id]

  floating = true
}

resource "terraform_data" "hostname" {
  count = var.SERVERS_NUM
  input = "node0${count.index}.${var.CLUSTER_TLD}"
}

resource "rustack_dns" "cluster_dns" {
  name       = "${var.CLUSTER_TLD}."
  project_id = data.rustack_project.iconicproject.id
}

resource "rustack_dns_record" "node_ws_record" {
  count  = var.SERVERS_NUM
  dns_id = resource.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${resource.terraform_data.hostname[count.index].output}."
  data   = resource.rustack_vm.cluster[count.index].floating_ip
}

resource "rustack_dns_record" "cluster_ws_record" {
  count  = var.SERVERS_NUM
  dns_id = resource.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${var.CLUSTER_TLD}."
  data   = resource.rustack_vm.cluster[count.index].floating_ip
}

resource "rustack_dns_record" "any_cluster_ws_record" {
  count  = var.SERVERS_NUM > 0 ? 1 : 0
  dns_id = resource.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "*.${var.CLUSTER_TLD}."
  data   = resource.rustack_vm.cluster[0].floating_ip
}
