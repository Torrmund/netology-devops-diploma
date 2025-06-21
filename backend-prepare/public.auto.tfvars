infrastructure_sa_params = {
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

infrastructure_backend_sa_static_key_path = "../infrastructure/.yc/infrastructure_sa_credentials"

infrastructure_sa_authorized_key_path = "../infrastructure/.yc/infrastructure_sa_key.json"

s3_bucket_kms_key_params = {
  name = "s3-bucket-kms-key"
  default_algorithm = "AES_256"
  rotation_period = "8760h"
}

s3_bucket_params = {
  name = "netology-diploma-tfstate"
  acl = "private"
}

state_ydb_name = "netology-diploma-tfstate-lock"

state_ydb_table_name = "netology-diploma-tfstate-lock-table"
