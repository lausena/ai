variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc3"
}

variable "droplet_size" {
  description = "Size of the droplet"
  type        = string
  default     = "s-2vcpu-2gb"
  
  validation {
    condition = contains([
      "s-1vcpu-1gb", "s-1vcpu-2gb", "s-2vcpu-2gb", "s-2vcpu-4gb", 
      "s-4vcpu-8gb", "s-6vcpu-16gb", "s-8vcpu-32gb", "s-16vcpu-64gb",
      "c-2", "c-4", "c-8", "c-16", "c-32",
      "m-2vcpu-16gb", "m-4vcpu-32gb", "m-8vcpu-64gb", "m-16vcpu-128gb"
    ], var.droplet_size)
    error_message = "Droplet size must be a valid DigitalOcean size. Common sizes: s-1vcpu-1gb, s-1vcpu-2gb, s-2vcpu-2gb, s-2vcpu-4gb, s-4vcpu-8gb."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "domain_name" {
  description = "Domain name for the application (optional)"
  type        = string
  default     = ""
}

variable "enable_backups" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "ssh_allowed_ips" {
  description = "List of IP addresses allowed to SSH to the droplet"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_allowed_ips" {
  description = "List of IP addresses allowed to access the app directly on port 8080"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "manage_dns_records" {
  description = "Whether to create/manage DNS records (set to false if records already exist)"
  type        = bool
  default     = false
}