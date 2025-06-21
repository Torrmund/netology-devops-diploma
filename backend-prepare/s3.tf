resource "yandex_storage_bucket" "state-bucket" {
  bucket = var.s3_bucket_params.name
  acl    = var.s3_bucket_params.acl

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.s3_bucket_kms_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
