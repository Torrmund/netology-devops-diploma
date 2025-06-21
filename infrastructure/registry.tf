resource "yandex_container_registry" "infrastructure_registry" {
  name = var.registry_params.name
  folder_id = var.folder_id
  labels = var.registry_params.labels
}

resource "yandex_container_repository" "demo_app_repository" {
  for_each = toset(var.repository_name)
  name = "${yandex_container_registry.infrastructure_registry.id}/${each.value}"
}

resource "yandex_iam_service_account" "registry_sa" {
  folder_id = var.folder_id
  name = var.registry_sa_name
  description = "Service account for container registry"
}

resource "yandex_container_registry_iam_binding" "puller_binding" {
  registry_id = yandex_container_registry.infrastructure_registry.id
  role = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.registry_sa.id}"
  ]
}

resource "yandex_container_registry_iam_binding" "pusher_binding" {
  registry_id = yandex_container_registry.infrastructure_registry.id
  role = "container-registry.images.pusher"
  members = [
    "serviceAccount:${yandex_iam_service_account.registry_sa.id}"
  ]
}

resource "yandex_iam_service_account_static_access_key" "registry_sa_static_key" {
  service_account_id = yandex_iam_service_account.registry_sa.id
  description        = "Static access key for container registry operations"
}

resource "local_sensitive_file" "registry_sa_key" {
  filename = var.registry_sa_key_filepath
  file_permission = 600

  content = <<EOF
[default]
aws_access_key_id = ${yandex_iam_service_account_static_access_key.registry_sa_static_key.access_key}
aws_secret_access_key = ${yandex_iam_service_account_static_access_key.registry_sa_static_key.secret_key}
EOF
}
