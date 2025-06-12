# Получение параметров созданного автоматически проекта по его имени (шаг 2)
data "rustack_project" "iconicproject" {
  name = "Мой проект"
}


data "rustack_dns" "cluster_dns" {
  name       = "${var.CLUSTER_TLD}."
  project_id = data.rustack_project.iconicproject.id
}
