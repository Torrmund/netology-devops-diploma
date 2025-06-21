resource "yandex_ydb_database_serverless" "state_ydb" {
  name      = var.state_ydb_name
  folder_id =  var.folder_id
  location_id = "ru-central1"
}

resource "aws_dynamodb_table" "state_ydb_table" {
  name = var.state_ydb_table_name
  region = "ru-central1"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}