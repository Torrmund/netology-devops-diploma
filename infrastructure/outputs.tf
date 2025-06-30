output "ycr_id" {
  value = yandex_container_registry.infrastructure_registry.id
}
output "grafana_url" {
  value = "http://${var.grafana_metadata.domain}"
}

output "teamcity_url" {
  value = "http://${var.teamcity_master_domain}"
}

output "teamcity_install_0master" {
  value = "Инфраструктура развернута! Можно приступать к установке TeamCity.\nСначала, установи master через\n'ansible-playbook -i ansible/inventory/teamcity_inventory.yml ansible/teamcity_install.yml -l teamcity_master'\nзатем переходи к установке агентов"
}

output "teamcity_install_agents" {
  value = "После инициализации мастера, запусти установку и настройку агентов:\n'ansible-playbook -i ansible/inventory/teamcity_inventory.yml ansible/teamcity_install.yml -l teamcity_agents'"
}
