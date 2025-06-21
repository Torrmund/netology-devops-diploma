resource "yandex_iam_service_account" "infrastructure_sa" {
    folder_id = var.folder_id
    name = var.infrastructure_sa_params.name
}

resource "yandex_resourcemanager_folder_iam_member" "infrastructure_sa_roles" {
  for_each = toset(var.infrastructure_sa_params.roles)
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.infrastructure_sa.id}"
}

resource "yandex_kms_symmetric_key_iam_member" "infrastructure_sa_access" {
  depends_on = [ yandex_kms_symmetric_key.s3_bucket_kms_key, yandex_iam_service_account.infrastructure_sa ]
  symmetric_key_id = yandex_kms_symmetric_key.s3_bucket_kms_key.id
  role = "kms.keys.encrypterDecrypter"
  member = "serviceAccount:${yandex_iam_service_account.infrastructure_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "infrastructure_sa_static_key" {
  service_account_id = yandex_iam_service_account.infrastructure_sa.id
  description        = "Static access key for S3 operations"
}

resource "yandex_iam_service_account_key" "infrastructure_sa_key" {
  service_account_id = yandex_iam_service_account.infrastructure_sa.id
}

# Передача кредов от созданного сервисного аккаунта в проект infrastructure
resource "null_resource" "infrastructure_sa_key" {
  depends_on = [ yandex_resourcemanager_folder_iam_member.infrastructure_sa_roles ]
  provisioner "local-exec" {
    command = "yc iam key create --folder-id ${var.folder_id} --service-account-name ${yandex_iam_service_account.infrastructure_sa.name} --output ${var.infrastructure_sa_authorized_key_path}"
  }
}

resource "local_sensitive_file" "infrastructure_sa_credentials" {
  filename = var.infrastructure_backend_sa_static_key_path
  file_permission = 600

  content = <<EOF
[default]
aws_access_key_id = ${yandex_iam_service_account_static_access_key.infrastructure_sa_static_key.access_key}
aws_secret_access_key = ${yandex_iam_service_account_static_access_key.infrastructure_sa_static_key.secret_key}
EOF
}
