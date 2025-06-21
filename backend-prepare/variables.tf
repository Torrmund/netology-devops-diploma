#----------------------------------------------------------------
# Переменные для доступа к облаку
#----------------------------------------------------------------

variable "cloud_id" {
  type = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "key_file" {
  type = string
  description = "Path to service account authorized key file"
}

#----------------------------------------------------------------
# Переменные сервисного аккаунта для поднятия инфраструктуры                             
#----------------------------------------------------------------

variable "infrastructure_sa_params" {
  type = object({
    name  = string
    roles = list(string)
  })
  default = {
    name = "infrastructure-sa"
    roles = [ "compute.editor",
              "vpc.admin",
              "storage.uploader",
              "dns.editor",
              "resource-manager.admin",
              "iam.serviceAccounts.admin",
              "k8s.admin",
              "ydb.editor",
              "container-registry.admin" ]
  }
  description = "Params of service account for infrastructure"
}

variable "infrastructure_backend_sa_static_key_path" {
  type = string
  default = "../infrastructure/.yc/infrastructure_sa_credentials"
  description = "Service account static key path for access to S3 bucket"
}

variable "infrastructure_sa_authorized_key_path" {
  type = string
  default = "../infrastructure/.yc/infrascrupture_sa_key.json"
  description = "Service account authorized key for connect to YC"
}

#----------------------------------------------------------------
# Переменные для создания ключа KMS (шифрование S3 бакета)                           
#----------------------------------------------------------------

variable "s3_bucket_kms_key_params" {
  type = object({
    name = string
    default_algorithm = string
    rotation_period = string
  })
  default = {
    name = "s3-bucket-kms-key"
    default_algorithm = "AES_256"
    rotation_period = "8760h"
  }
  description = "Params of s3 bucket encryption kms key"
}

#----------------------------------------------------------------
# Переменные для создания S3 бакета                          
#----------------------------------------------------------------

variable "s3_bucket_params" {
  type = object({
    name = string
    acl = string
  })
  default = {
    name = "netology-diploma-tfstate"
    acl = "private"
  }
  description = "Params of s3 bucket for infrastructure backend"
}

#----------------------------------------------------------------
# Переменные для создания YDB                         
#----------------------------------------------------------------

variable "state_ydb_name" {
  type = string
  default = "netology-diploma-tfstate-lock"
}

variable "state_ydb_table_name" {
  type = string
  default = "netology-diploma-tfstate-lock-table"
  description = "Name of YDB table for state lock"
}
