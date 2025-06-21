output "ydb_endpoint" {
  value = yandex_ydb_database_serverless.state_ydb.document_api_endpoint
}

output "state_backet_name" {
  value = yandex_storage_bucket.state-bucket.bucket
}

output "state_ydb_table_name" {
  value = aws_dynamodb_table.state_ydb_table.name
}

output "sa_static_key_path" {
  value = "${var.infrastructure_backend_sa_static_key_path}"
}

output "sa_authorized_key_path" {
  value = "${var.infrastructure_sa_authorized_key_path}"
}