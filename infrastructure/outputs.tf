output "droplet_ip" {
  description = "Public IP address of the droplet"
  value       = digitalocean_droplet.evalpoint.ipv4_address
}

output "droplet_id" {
  description = "ID of the created droplet"
  value       = digitalocean_droplet.evalpoint.id
}

output "droplet_name" {
  description = "Name of the created droplet"
  value       = digitalocean_droplet.evalpoint.name
}

output "ssh_command" {
  description = "SSH command to connect to the droplet"
  value       = "ssh root@${digitalocean_droplet.evalpoint.ipv4_address}"
}

output "app_url" {
  description = "URL to access the application"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${digitalocean_droplet.evalpoint.ipv4_address}"
}

output "direct_app_url" {
  description = "Direct URL to access the application on port 8080"
  value       = "http://${digitalocean_droplet.evalpoint.ipv4_address}:8080"
}