vpc_params = {
  name = "infra-vpc"
  subnets = {
    "infra-ru-central1-a" = { zone = "ru-central1-a", cidr = "10.0.10.0/24" },
    "infra-ru-central1-b" = { zone = "ru-central1-b", cidr = "10.0.11.0/24" },
    "infra-ru-central1-d" = { zone = "ru-central1-d", cidr = "10.0.12.0/24" },
  }
}

registry_params = {
  name = "infrastructure-registry"
  labels = {
    "env" = "infrastructure"
    "team" = "devops"
  }
}
repository_name = ["notes-app"]
registry_sa_name = "registry-sa"
registry_sa_key_filepath = "./.yc/registry_sa_key.json"

dns_zone_params = {
  name = "infrastructure-dns-zone"
  zone = "torrmund.xyz."
  is_public = true
}

k8s_resource_manager_sa_params = {
  name = "k8s-resource-manager"
  description = "Service account for Kubernetes resource management"
}

k8s_resource_manager_sa_key_filepath = "./.yc/k8s_sa_key.json"

hosts_sa_params = {
  name = "hosts-sa"
  description = "Service account for hosts management"
  roles = ["container-registry.images.puller"]
}

k8s_cluster_metadata = {
  name = "netology-k8s-cluster"
  region = "ru-central1"
  version = "1.30"
  public_ip = true
  auto_upgrade = false
  network_policy_provider = "CALICO"
  release_channel = "STABLE"
}

k8s_node_group_params = {
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

kube_config = "./.kube/kube_config"

ingress_metadata = {
  name = "ingress-nginx"
  namespace = "ingress"
  version = "4.8.3"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
}

monitoring_metadata = {
  name = "kube-prometheus-stack"
  namespace = "monitoring"
  version = "61.9.0"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
}

grafana_metadata = {
  domain = "grafana.torrmund.xyz"
  admin_user = "admin"
  admin_password = "admin"
}

postgresql_metadata = {
  name = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version = "16.7.11"
  database = "notes-app"
  existing_secret = ""
  primary_persistence_enabled = true
  primary_persistence_size = "5Gi"
}

demo_app_namespace = "notes-app"

demo_app_domain = "notes.torrmund.xyz"

teamcity_master_vm_metadata = {
  name = "teamcity-master"
  zone = "ru-central1-a"
  platform_id = "standard-v2"
  hostname = "teamcity-master"
  cores = 2
  memory = 4
  core_fraction = 100
  disk_size = 30
  subnet_index = "infra-ru-central1-a"
  nat = true
  preemptible = true
  os_family = "ubuntu-2204-lts"
}

teamcity_agents_vm_metadata = {
  count = 1
    name = "teamcity-agent"
    zone = "ru-central1-a"
    platform_id = "standard-v2"
    hostname = "teamcity-agent"
    cores = 2
    memory = 4
    core_fraction = 100
    disk_size = 30
    subnet_index = "infra-ru-central1-a"
    nat = true
    preemptible = true
}

teamcity_install_metadata = {
  ansible_user = "ubuntu"
  terraform_version = "1.11.3"
  helm_version = "3.17.3"
}

teamcity_master_domain = "teamcity.torrmund.xyz"

teamcity_distro_filepath = "/home/emav/TeamCity-2025.03.3.tar.gz"
