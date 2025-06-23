resource "yandex_iam_service_account" "k8s_resource_manager" {
  name        = var.k8s_resource_manager_sa_params.name
  description = var.k8s_resource_manager_sa_params.description 
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_resource_manager_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_resource_manager.id}"
}

resource "null_resource" "k8s_resource_manager_sa_key" {
  depends_on = [yandex_resourcemanager_folder_iam_member.k8s_resource_manager_editor]
  provisioner "local-exec" {
    command = "yc iam key create --folder-id ${var.folder_id} --service-account-id ${yandex_iam_service_account.k8s_resource_manager.id} --output ${var.k8s_resource_manager_sa_key_filepath}"
  }
}

resource "yandex_iam_service_account" "hosts_sa" {
  name        = var.hosts_sa_params.name
  description = var.hosts_sa_params.description
}

resource "yandex_resourcemanager_folder_iam_member" "hosts_sa_roles" {
  for_each = toset(var.hosts_sa_params.roles)
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.hosts_sa.id}"
}


resource "yandex_kubernetes_cluster" "regional_cluster" {
  name = var.k8s_cluster_metadata.name
  network_id = "${yandex_vpc_network.infrastructure_vpc.id}"

  master {
    regional {
      region = var.k8s_cluster_metadata.region
    

    dynamic "location" {
      for_each = [for s in values(yandex_vpc_subnet.infrastructure_vpc_subnets) : {
        zone = s.zone
        subnet_id = s.id
      }]
      content {
        zone = location.value.zone
        subnet_id = location.value.subnet_id
      }
    }
    }
    
    version = var.k8s_cluster_metadata.version
    public_ip = var.k8s_cluster_metadata.public_ip

    maintenance_policy {
      auto_upgrade = var.k8s_cluster_metadata.auto_upgrade
    }
  }
  service_account_id = yandex_iam_service_account.k8s_resource_manager.id
  node_service_account_id = yandex_iam_service_account.hosts_sa.id

  network_policy_provider = var.k8s_cluster_metadata.network_policy_provider

  release_channel = var.k8s_cluster_metadata.release_channel

  depends_on = [ 
    yandex_resourcemanager_folder_iam_member.k8s_resource_manager_editor,
    yandex_resourcemanager_folder_iam_member.hosts_sa_roles
   ]
}

resource "yandex_kubernetes_node_group" "name" {
  for_each = { for key, subnet in yandex_vpc_subnet.infrastructure_vpc_subnets : key => subnet if subnet.zone != null }

  cluster_id = yandex_kubernetes_cluster.regional_cluster.id
  name = "${var.k8s_node_group_params.name}-${each.key}"
  version = var.k8s_cluster_metadata.version

  instance_template {
    platform_id = var.k8s_node_group_params.platform_id

    network_interface {
      nat = var.k8s_node_group_params.network_interface.nat
      subnet_ids = [each.value.id]
    }

    resources {
      memory = var.k8s_node_group_params.resources.memory
      cores  = var.k8s_node_group_params.resources.cores
      core_fraction = var.k8s_node_group_params.resources.core_fraction
    }

    boot_disk {
      type = var.k8s_node_group_params.boot_disk.type
      size = var.k8s_node_group_params.boot_disk.size
    }

    scheduling_policy {
      preemptible = var.k8s_node_group_params.scheduling_policy.preemptible
    }

    container_runtime {
      type = var.k8s_node_group_params.container_runtime.type
    }

    metadata = {
      ssh_keys = "emav:${var.vms_ssh_public_key}"
    }
  }

    scale_policy {
      auto_scale {
        initial = var.k8s_node_group_params.scale_policy.auto_scale.initial
        min = var.k8s_node_group_params.scale_policy.auto_scale.min
        max = var.k8s_node_group_params.scale_policy.auto_scale.max
      }
    }

    allocation_policy {
        location {
            zone = each.value.zone
        }
    }
}

# Получаем kubeconfig для локального доступа к кластеру и генерируем kubeconfig для CI/CD
resource "null_resource" "get_kube_config" {
    depends_on = [yandex_kubernetes_node_group.name]
    
    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<EOT
        yc config set service-account-key ${var.k8s_resource_manager_sa_key_filepath} && \ 
        yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.regional_cluster.id} --force --external --format yaml && \
        ./generate_kube_config.sh --cluster-name ${yandex_kubernetes_cluster.regional_cluster.name} --cluster-id ${yandex_kubernetes_cluster.regional_cluster.id} && \
        yc config set service-account-key ${var.service_account_key_filepath}
        EOT
    }
}

