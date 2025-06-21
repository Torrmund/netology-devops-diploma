resource "yandex_kms_symmetric_key" "s3_bucket_kms_key" {
  name              = var.s3_bucket_kms_key_params.name
  default_algorithm = var.s3_bucket_kms_key_params.default_algorithm
  rotation_period   = var.s3_bucket_kms_key_params.rotation_period
}
