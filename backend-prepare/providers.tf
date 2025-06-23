terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.140.1"
    }
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
    time = {
      source = "hashicorp/time"
      version = "0.13.1"
    }
  }
  required_version = "~>1.11.0"
}

provider "yandex" {
  service_account_key_file = var.key_file
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}

provider "aws" {
  region = "ru-central1"
  endpoints {
    dynamodb = yandex_ydb_database_serverless.state_ydb.document_api_endpoint
  }
  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_region_validation = true
  skip_requesting_account_id = true
}
