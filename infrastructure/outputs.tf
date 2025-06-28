output "teamcity_agents_ips" {
  description = "Public IPs of TeamCity agents"
  value = yandex_compute_instance.teamcity_agents[*].network_interface.0.nat_ip_address
}