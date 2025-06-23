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

variable "vms_ssh_public_key" {
  type = string
  description = "Default ssh public key, that will be store on remote machine"
}

variable "ssh_private_key_filepath" {
  type = string
  description = "Path to the private SSH key for accessing VMs"
  default = "~/.ssh/id_ed25519"
}

variable "service_account_key_filepath" {
  type = string
  default = "./.yc/infrastructure_sa_key.json"
}

#----------------------------------------------------------------
# Переменные для создания VPC под инфраструктуру                         
#----------------------------------------------------------------

variable "vpc_params" {
  description = "Params of infrastructure VPC"
  type = object({
    name = string
    subnets = map(object({
      zone = string
      cidr = string
    }))
  })
  default = {
    name = "infra-vpc"
    subnets = {
      "infra-ru-central1-a" = { zone = "ru-central1-a", cidr = "10.0.10.0/24" },
      "infra-ru-central1-b" = { zone = "ru-central1-b", cidr = "10.0.11.0/24" },
      "infra-ru-central1-d" = { zone = "ru-central1-d", cidr = "10.0.12.0/24" },
    }
  }

}

#----------------------------------------------------------------
# Переменные для container registry
#----------------------------------------------------------------
variable "registry_params" {
  description = "Params of infrastructure registry"
  type = object({
    name = string
    labels = map(string)
  })
  default = {
    name = "infrastructure-registry"
    labels = {
      "env" = "infrastructure"
      "team" = "devops"
    }
  }
}

variable "repository_name" {
  type = set(string)
  description = "Set of repository names in the container registry"
  default = ["demo-app"]
}

variable "registry_sa_name" {
  type = string
  description = "Name of the service account for container registry"
  default = "registry-sa"
}

variable "registry_sa_key_filepath" {
  type = string
  description = "Filepath for the static access key of the service account for container registry"
  default = "./.yc/registry_sa_credentials"
}

#----------------------------------------------------------------
# Переменные для DNS зоны
#----------------------------------------------------------------
variable "dns_zone_params" {
  description = "Params of infrastructure DNS zone"
  type = object({
    name = string
    zone = string
    is_public = bool
  })
  default = {
    name = "infrastructure-dns-zone"
    zone = "infrastructure.example.com."
    is_public = true
  }
}

#----------------------------------------------------------------
# Переменные для сервисных аккаунтов k8s
#----------------------------------------------------------------

variable "k8s_resource_manager_sa_params" {
  description = "Params for Kubernetes resource manager service account"
  type = object({
    name = string
    description = string
  })
  default = {
    name = "k8s-resource-manager"
    description = "Service account for Kubernetes resource management"
  }
}

variable "k8s_resource_manager_sa_key_filepath" {
  description = "Filepath for the static access key of the Kubernetes resource manager service account"
  type = string
  default = "./.yc/k8s__sa_key.json"
}

variable "hosts_sa_params" {
  description = "Params for hosts management service account"
  type = object({
    name = string
    description = string
    roles = set(string)
  })
  default = {
    name = "hosts-sa"
    description = "Service account for hosts management"
    roles = ["container-registry.images.puller"]
  }
}

#----------------------------------------------------------------
# Переменные для Kubernetes кластера
#----------------------------------------------------------------
variable "k8s_cluster_metadata" {
  description = "Metadata for Kubernetes cluster"
  type = object({
    name = string
    region = string
    version = string
    public_ip = bool
    auto_upgrade = bool
    network_policy_provider = string
    release_channel = string
  })
  default = {
    name = "netology-k8s-cluster"
    region = "ru-central1"
    version = "1.30"
    public_ip = true
    auto_upgrade = false
    network_policy_provider = "CALICO"
    release_channel = "STABLE"
  }
}

#----------------------------------------------------------------
# Переменные для создания нод k8s
#----------------------------------------------------------------
variable "k8s_node_group_params" {
  description = "values for Kubernetes node group"
  type = object({
    name = string
    version = string
    platform_id = string
    resources = object({
      cores = number
      memory = number
      core_fraction = number
    })
    network_interface = object({
      nat = bool
    })
    boot_disk = object({
      type = string
      size = number
    })
    scheduling_policy = object({
      preemptible = bool
    })
    container_runtime = object({
      type = string
    })
    scale_policy = object({
        auto_scale = object({
          initial = number
          max = number
          min = number
        })
      })
  })
  default = {
    name = "netology-k8s-node-group"
    version = "1.30"
    platform_id = "standard-v2"
    resources = {
      cores = 2
      memory = 4
      core_fraction = 100
    }
    network_interface = {
      nat = true
    }
    boot_disk = {
      type = "network-ssd"
      size = 30
    }
    scheduling_policy = {
      preemptible = true
    }
    container_runtime = {
      type = "containerd"
    }
    scale_policy = {
      auto_scale = {
        initial = 1
        max = 2
        min = 1
      }
    }
  }
}

#----------------------------------------------------------------
# Переменные для Helm
#----------------------------------------------------------------
variable "kube_config" {
  type = string
  description = "Path to kubeconfig file for accessing the Kubernetes cluster"
  default = "~/.kube/config"
}

variable "ingress_metadata" {
  description = "Metadata for the ingress controller"
  type = object({
    name = string
    namespace = string
    version = string
    repository = string
    chart = string
  })
  default = {
    name = "ingress-nginx"
    namespace = "ingress"
    version = "4.8.3"
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart = "ingress-nginx"
  } 
}

variable "monitoring_metadata" {
  description = "Metadata for the monitoring stack"
  type = object({
    name = string
    namespace = string
    version = string
    repository = string
    chart = string
  })
  default = {
    name = "kube-prometheus-stack"
    namespace = "monitoring"
    version = "61.9.0"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"
  }
}

#----------------------------------------------------------------
# Переменные для Grafana
#----------------------------------------------------------------
variable "grafana_metadata" {
  description = "values for Grafana Helm chart"
  type = object({
    domain = string
    admin_user = string
    admin_password = string
  })
  default = {
    domain = "grafana.example.com"
    admin_user = "admin"
    admin_password = "admin"
  }
}

#----------------------------------------------------------------
# Переменные для PostgreSQL
#----------------------------------------------------------------
variable "postgresql_metadata" {
  description = "Metadata for PostgreSQL Helm chart"
  type = object({
    name = string
    repository = string
    chart = string
    version = string
    database = string
    existing_secret = string
    primary_persistence_enabled = bool
    primary_persistence_size = string
  })
  default = {
    name = "postgresql"
    repository = "https://charts.bitnami.com/bitnami"
    chart = "postgresql"
    version = "16.7.11"
    database = "demo_db"
    existing_secret = ""
    primary_persistence_enabled = true
    primary_persistence_size = "5Gi"
  }
}

variable "demo_app_namespace" {
  type = string
  description = "Namespace for the demo application in Kubernetes"
  default = "demo-app"
}

variable "postgresql_username" {
  type = string
  description = "Username for PostgreSQL"
  default = "demo_user"
  sensitive = true
}

variable "postgresql_password" {
  type = string
  description = "Password for PostgreSQL"
  default = "demo_password"
  sensitive = true
}

#----------------------------------------------------------------
# Переменные для Jenkins
#----------------------------------------------------------------
variable "jenkins_vm_metadata" {
  description = "Metadata for Jenkins VM"
  type = object({
    name = string
    zone = string
    platform_id = string
    hostname = optional(string, null) # Optional field for hostname
    cores = number
    memory = number
    core_fraction = number
    disk_size = number
    subnet_index = string
    nat = bool
    preemptible = bool
    os_family = string
  })
  default = {
    name = "jenkins"
    zone = "ru-central1-a"
    platform_id = "standard-v2"
    hostname = "jenkins"
    cores = 2
    memory = 4
    core_fraction = 100
    disk_size = 30
    subnet_index = "infra-ru-central1-a"
    nat = true
    preemptible = true
    os_family = "ubuntu-2204-lts"
  }
}

variable "jenkins_install_metadata" {
  description = "values for Jenkins installation"
  type = object({
    ansible_user = string
    jenkins_version = string
    terraform_version = string
    helm_version = string
  })
  default = {
    ansible_user = "ubuntu"
    jenkins_version = "2.504.2"
    terraform_version = "1.11.3"
    helm_version = "3.17.3"
  }
}