data "yandex_compute_image" "ubuntu" {
  family = var.teamcity_master_vm_metadata.os_family
}

resource "yandex_compute_instance" "teamcity_master" {
  name = var.teamcity_master_vm_metadata.name
  zone = var.teamcity_master_vm_metadata.zone
  platform_id = var.teamcity_master_vm_metadata.platform_id
  hostname = var.teamcity_master_vm_metadata.hostname
  resources {
    cores = var.teamcity_master_vm_metadata.cores
    memory = var.teamcity_master_vm_metadata.memory
    core_fraction = var.teamcity_master_vm_metadata.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size = var.teamcity_master_vm_metadata.disk_size
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.infrastructure_vpc_subnets[var.teamcity_master_vm_metadata.subnet_index].id
    nat = var.teamcity_master_vm_metadata.nat
  }
  scheduling_policy {
    preemptible = var.teamcity_master_vm_metadata.preemptible
  }
  metadata = {
    ssh-keys = "ubuntu:${var.vms_ssh_public_key}"
  }
}

resource "yandex_compute_instance" "teamcity_agents" {
  count = var.teamcity_agents_vm_metadata.count
  name = "${var.teamcity_agents_vm_metadata.name}-${count.index + 1}"
  zone = var.teamcity_agents_vm_metadata.zone
  platform_id = var.teamcity_agents_vm_metadata.platform_id
  hostname = "${var.teamcity_agents_vm_metadata.hostname}-${count.index + 1}"
  resources {
    cores = var.teamcity_agents_vm_metadata.cores
    memory = var.teamcity_agents_vm_metadata.memory
    core_fraction = var.teamcity_agents_vm_metadata.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size = var.teamcity_agents_vm_metadata.disk_size
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.infrastructure_vpc_subnets[var.teamcity_agents_vm_metadata.subnet_index].id
    nat = var.teamcity_agents_vm_metadata.nat
  }
  scheduling_policy {
    preemptible = var.teamcity_agents_vm_metadata.preemptible
  }
  metadata = {
    ssh-keys = "ubuntu:${var.vms_ssh_public_key}"
  }
}

resource "local_file" "teamcity_inventory" {
    content = templatefile("${path.module}/templates/teamcity_inventory.yml.tftpl", {
      teamcity_master_nat_ip = yandex_compute_instance.teamcity_master.network_interface[0].nat_ip_address
      ansible_user = var.teamcity_install_metadata.ansible_user
      ansible_ssh_private_key_file = var.ssh_private_key_filepath
      teamcity_distro_filepath = var.teamcity_distro_filepath
      teamcity_server_domain = var.teamcity_master_domain
      teamcity_agent_ips = yandex_compute_instance.teamcity_agents[*].network_interface.0.nat_ip_address
      terraform_version = var.teamcity_install_metadata.terraform_version
      kubernetes_version = var.k8s_cluster_metadata.version
      helm_version = var.teamcity_install_metadata.helm_version
      registry_sa_key_filepath = var.registry_sa_key_filepath
      infrastructure_sa_key_filepath = var.service_account_key_filepath
      infrastructure_sa_credentials_filepath = var.service_account_credentials_filepath
      kubeconfig_filepath = var.kube_config
      demo_app_helm_values_filepath = var.notes_app_helm_values_filepath
    })

    filename = "${path.module}/ansible/inventory/teamcity_inventory.yml"
}

# resource "null_resource" "install_teamcity" {
#   depends_on = [yandex_compute_instance.teamcity_master, yandex_compute_instance.teamcity_agents, local_file.teamcity_inventory, null_resource.get_kube_config]

#   provisioner "local-exec" {
#     command = "ansible-playbook -i ${local_file.teamcity_inventory.filename} ansible/teamcity_install.yml -vv"
#     interpreter = ["bash", "-c"]
#   }
# }
