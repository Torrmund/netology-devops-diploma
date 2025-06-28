resource "local_file" "notes_app_helm_values" {
  content = templatefile("${path.module}/templates/notes_app.yaml.tftpl", {
    demo_app_namespace = var.demo_app_namespace
    demo_app_replica_count = var.demo_app_replica_count
    registry_id = yandex_container_registry.infrastructure_registry.id
    demo_app_domain = var.demo_app_domain
    database_host = var.postgresql_metadata.name
    database_name = var.postgresql_metadata.database
  })
  filename = "${var.notes_app_helm_values_filepath}"
}
