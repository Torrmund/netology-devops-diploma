data "yandex_compute_image" "ubuntu" {
  family = var.jenkins_vm_metadata.os_family
}

resource "yandex_compute_instance" "jenkins" {
  name = var.jenkins_vm_metadata.name
  zone = var.jenkins_vm_metadata.zone
  platform_id = var.jenkins_vm_metadata.platform_id
  hostname = var.jenkins_vm_metadata.hostname
  resources {
    cores = var.jenkins_vm_metadata.cores
    memory = var.jenkins_vm_metadata.memory
    core_fraction = var.jenkins_vm_metadata.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size = var.jenkins_vm_metadata.disk_size
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.infrastructure_vpc_subnets[var.jenkins_vm_metadata.subnet_index].id
    nat = var.jenkins_vm_metadata.nat
  }
  scheduling_policy {
    preemptible = var.jenkins_vm_metadata.preemptible
  }
  metadata = {
    ssh-keys = "ubuntu:${var.vms_ssh_public_key}"
  }
}

resource "local_file" "jenkins_inventory" {
  content = templatefile("${path.module}/templates/jenkins_inventory.yml.tftpl" , {
    jenkins_nat_ip = yandex_compute_instance.jenkins.network_interface[0].nat_ip_address
    ansible_user = var.jenkins_install_metadata.ansible_user
    ansible_ssh_private_key_file = var.ssh_private_key_filepath
    jenkins_version = var.jenkins_install_metadata.jenkins_version
    terraform_version = var.jenkins_install_metadata.terraform_version
    kubernetes_version = var.k8s_cluster_metadata.version
    helm_version = var.jenkins_install_metadata.helm_version
    })

    filename = "${path.module}/ansible/inventory/jenkins_inventory.yml"
}

# resource "null_resource" "install_jenkins" {
#   depends_on = [yandex_compute_instance.jenkins, local_file.jenkins_inventory]

#   provisioner "local-exec" {
#     command = "ansible-playbook -i ${local_file.jenkins_inventory.filename} ansible/jenkins_install.yml -vv"
#     interpreter = ["bash", "-c"]
#   }
# }