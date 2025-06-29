terraform {
  backend "s3" {
    region = "ru-central1"

    bucket = "netology-diploma-tfstate"
    key = "infrastructure/terraform.tfstate"
    dynamodb_table = "netology-diploma-tfstate-lock-table"
    

    skip_region_validation = true
    skip_credentials_validation = true
    skip_requesting_account_id = true
    skip_s3_checksum = true

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
      dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gmlu2hfoi2rdhigrb4/etn0oi6im2fhdjmrkmf2"
    }
  }

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.140.1"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}

provider "yandex" {
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  service_account_key_file = var.service_account_key_filepath
}

provider "helm" {
  kubernetes = {
    config_path = pathexpand(var.kube_config)
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kube_config)
}

provider "kubectl" {
  config_path = pathexpand(var.kube_config)
}
