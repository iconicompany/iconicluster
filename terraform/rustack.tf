
# Получение параметров созданного автоматически проекта по его имени (шаг 2)
data "rustack_project" "iconicproject" {
  name = "Мой проект"
}

# Получение параметров доступного гипервизора KVM по его имени и по id проекта (шаг 3)
data "rustack_hypervisor" "kvm" {
  project_id = data.rustack_project.iconicproject.id
  name       = "РУСТЭК"
}

# Создание ВЦОД KVM.
# Задаём его имя, указываем id проекта, который получили на шаге 2 при обращении к datasource rustack_project
# Указываем id гипервизора, который получили на шаге 3 при обращении к datasource rustack_hypervisor (шаг 4)
# replace data with resource and uncomment hypervisor_id to create
data "rustack_vdc" "iconicvdc" {
  name          = "Iconic KVM"
  project_id    = data.rustack_project.iconicproject.id
  #hypervisor_id = data.rustack_hypervisor.kvm.id
}

# Получение параметров автоматически созданной при создании ВЦОД сервисной сети по её имени и id созданного ВЦОД, который получили на шаге 4 при создании resource rustack_vdc (шаг 5)
data "rustack_network" "iconicnet" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Сеть"
}

# Получение параметров доступного типа дисков по его имени и id созданного ВЦОД, который получили на шаге 4 при создании resource rustack_vdc (шаг 6)
data "rustack_storage_profile" "ssd" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "ssd"
}

# Получение параметров доступного шаблона ОС по его имени и id созданного ВЦОД, который получили на шаге 4 при создании resource rustack_vdc (шаг 7)
data "rustack_template" "ubuntu22" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Ubuntu 22.04"
}
