terraform {
  required_version = ">= 1.0"
  
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Get existing SSH keys to find one that matches our public key
data "digitalocean_ssh_keys" "existing" {}

locals {
  our_public_key = trimspace(file(var.ssh_public_key_path))
  matching_key = try(
    [for key in data.digitalocean_ssh_keys.existing.ssh_keys : key if key.public_key == local.our_public_key][0],
    null
  )
}

# Only create SSH key if we don't have a matching one
resource "digitalocean_ssh_key" "evalpoint" {
  count      = local.matching_key == null ? 1 : 0
  name       = "evalpoint-${var.environment}-${random_id.key_suffix.hex}"
  public_key = local.our_public_key
}

resource "random_id" "key_suffix" {
  byte_length = 4
}

# Create a new droplet
resource "digitalocean_droplet" "evalpoint" {
  image     = "ubuntu-25-04-x64"
  name      = "evalpoint-${var.environment}"
  region    = var.region
  size      = var.droplet_size
  ssh_keys  = [local.matching_key != null ? local.matching_key.fingerprint : digitalocean_ssh_key.evalpoint[0].fingerprint]
  
  # Enable monitoring and backups
  monitoring = true
  backups    = var.enable_backups
  
  # User data script for initial setup
  user_data = templatefile("${path.module}/user_data.sh", {
    docker_compose_content = base64encode(file("${path.module}/../docker-compose.yml"))
    nginx_config_content   = base64encode(templatefile("${path.module}/nginx.conf.tpl", {
      domain_name = var.domain_name
    }))
    app_env = var.environment
  })

  tags = [
    "environment:${var.environment}",
    "project:evalpoint",
    "managed-by:terraform"
  ]
}

# Create a firewall
resource "digitalocean_firewall" "evalpoint" {
  name = "evalpoint-${var.environment}-firewall"

  droplet_ids = [digitalocean_droplet.evalpoint.id]

  # SSH access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_allowed_ips
  }

  # HTTP
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Application port (for direct access during development)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8080"
    source_addresses = var.app_allowed_ips
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Skip domain creation if it already exists - manage DNS records only
# Note: If domain exists, you'll need to import it or manage it manually

# Only create DNS records if explicitly enabled
resource "digitalocean_record" "evalpoint_a" {
  count  = var.domain_name != "" && var.manage_dns_records ? 1 : 0
  domain = var.domain_name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.evalpoint.ipv4_address
  ttl    = 300
}

resource "digitalocean_record" "evalpoint_www" {
  count  = var.domain_name != "" && var.manage_dns_records ? 1 : 0
  domain = var.domain_name
  type   = "CNAME"
  name   = "www"
  value  = "@"
  ttl    = 300
}