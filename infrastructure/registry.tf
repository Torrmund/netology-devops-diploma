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

resource "null_resource" "registry_sa_key" {
  depends_on = [ yandex_iam_service_account.registry_sa, 
                  yandex_container_registry_iam_binding.puller_binding, 
                  yandex_container_registry_iam_binding.pusher_binding,
                  yandex_container_repository.demo_app_repository ]
  provisioner "local-exec" {
    command = "yc iam key create --folder-id ${var.folder_id} --service-account-id ${yandex_iam_service_account.registry_sa.id} --output ${var.registry_sa_key_filepath}"
  }
}
