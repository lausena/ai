# EvalPoint Infrastructure

Terraform configuration to deploy EvalPoint Flask application on DigitalOcean with production-ready setup including Docker, Nginx, SSL, and monitoring.

## What Gets Deployed

- **Ubuntu 24.04** droplet with security hardening
- **Docker & Docker Compose** for containerization
- **Nginx** reverse proxy with SSL termination
- **UFW firewall** with fail2ban intrusion prevention
- **Let's Encrypt SSL** certificates with auto-renewal
- **Monitoring** and log rotation
- **Application directory** at `/opt/evalpoint`

## Prerequisites

1. **DigitalOcean account** with API token
2. **SSH key pair** for server access  
3. **Terraform** installed locally
4. **Domain name** (optional but recommended)
5. **Docker image** in a registry or source code to build

## Quick Start

### 1. Install Terraform

```bash
# macOS
brew install terraform

# Ubuntu/Debian
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

### 2. Configure Variables

```bash
cd infrastructure
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
# Required
do_token = "your-digitalocean-api-token"
ssh_public_key_path = "~/.ssh/id_rsa.pub"

# Optional
domain_name = "evalpoint.com"
environment = "prod"
droplet_size = "s-2vcpu-2gb"
region = "nyc3"
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review deployment plan
terraform plan

# Deploy infrastructure
terraform apply
```

### 4. Complete Setup

After Terraform completes, run the post-deployment setup:

```bash
# Copy setup script to server
terraform output -raw ssh_command  # Get SSH command
scp post-deploy-setup.sh root@YOUR_SERVER_IP:/tmp/

# SSH to server and complete setup
ssh root@YOUR_SERVER_IP
chmod +x /tmp/post-deploy-setup.sh
/tmp/post-deploy-setup.sh
```

The setup script will:
- Configure Docker registry authentication
- Deploy your application
- Set up SSL certificates
- Perform health checks

## Configuration Options

### Droplet Sizes
- `s-1vcpu-1gb` - $4/month (development)
- `s-2vcpu-2gb` - $12/month (recommended)
- `s-4vcpu-8gb` - $24/month (high traffic)

### Regions
- `nyc1`, `nyc3` - New York
- `sfo3` - San Francisco
- `ams3` - Amsterdam
- `lon1` - London
- `sgp1` - Singapore

### Security Options
```hcl
# Restrict SSH access to your IP only
ssh_allowed_ips = ["YOUR.IP.ADDRESS/32"]

# Enable automated backups
enable_backups = true
```

## Application Deployment

### Option 1: Docker Registry (Recommended)

```bash
# Build and push your image
docker build --platform linux/amd64 -t evalpoint .
docker tag evalpoint your-registry/evalpoint:latest
docker push your-registry/evalpoint:latest

# Update docker-compose.yml on server
# image: your-registry/evalpoint:latest
```

### Option 2: Build on Server

```bash
# Copy source code to server
scp -r . root@YOUR_SERVER_IP:/opt/evalpoint/app/

# SSH and build
ssh root@YOUR_SERVER_IP
cd /opt/evalpoint/app
docker build -t evalpoint .
```

## SSL Certificate Setup

SSL certificates are automatically obtained during post-deployment setup if:
1. You provide a domain name
2. DNS is configured correctly
3. Domain points to your server IP

### Manual SSL Setup
```bash
# On your server
certbot --nginx -d your-domain.com -d www.your-domain.com --non-interactive --agree-tos --email admin@your-domain.com
```

## DNS Configuration

Configure these DNS records at your domain registrar:

| Type  | Name | Value           | TTL |
|-------|------|-----------------|-----|
| A     | @    | YOUR_SERVER_IP  | 300 |
| CNAME | www  | @               | 300 |

Verify with:
```bash
nslookup your-domain.com
ping your-domain.com
```

## Maintenance

### Application Management
```bash
# View logs
docker compose logs -f

# Restart application  
docker compose restart

# Update application
docker compose pull && docker compose up -d --remove-orphans
```

### System Management
```bash
# Update system packages
apt update && apt upgrade -y

# Check services
systemctl status nginx docker

# View firewall status
ufw status

# Check SSL certificate
certbot certificates
```

### Monitoring
- Health checks run every 5 minutes
- Logs are automatically rotated
- SSL certificates auto-renew
- Failed login attempts are blocked by fail2ban

## File Structure

```
infrastructure/
├── main.tf                    # Core infrastructure
├── variables.tf               # Input variables  
├── outputs.tf                 # Output values
├── user_data.sh              # Server initialization
├── nginx.conf.tpl            # Nginx configuration template
├── post-deploy-setup.sh      # Post-deployment setup script
├── terraform.tfvars.example  # Configuration template
├── DOCKER-AUTH.md            # Docker registry authentication guide
└── README.md                 # This file
```

## Troubleshooting

### Common Issues

**SSH Key Already Exists**
- Use different environment name: `environment = "prod2"`
- Or delete existing key in DigitalOcean console

**Domain DNS Not Propagating**
- Wait 5-60 minutes for DNS propagation
- Verify with `nslookup your-domain.com`

**Application Not Starting**
```bash
# Check container logs
docker compose logs

# Check if image exists
docker images

# Test manually
docker run --rm -p 8080:8080 your-image
```

**SSL Certificate Fails**
- Ensure domain points to server IP
- Check firewall allows HTTP/HTTPS
- Verify nginx is running: `systemctl status nginx`

**Static Files Missing (CSS/JS)**
```bash
# Check if files exist in container
docker compose exec web ls -la /app/static/

# Copy static files to nginx location
docker cp $(docker compose ps -q web):/app/static/. /opt/evalpoint/static/
chown -R www-data:www-data /opt/evalpoint/static
```

### Getting Help

1. Check application logs: `docker compose logs`
2. Check system logs: `journalctl -u nginx -f`
3. Run health checks: `/tmp/post-deploy-setup.sh`
4. Check Terraform state: `terraform show`

### Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Security Features

- **Firewall**: Only SSH, HTTP, HTTPS ports open
- **Fail2ban**: Automatic IP blocking for failed logins
- **SSL/TLS**: Automatic HTTPS with security headers
- **Non-root containers**: Application runs with limited privileges
- **Security updates**: Automatic system updates
- **Rate limiting**: Protection against DDoS attacks

## Cost Estimate

| Component | Monthly Cost |
|-----------|-------------|
| Droplet (s-2vcpu-2gb) | $12 |
| Backups (optional) | $1.20 |
| **Total** | **~$13/month** |

## Support

For issues with this infrastructure:
1. Check the troubleshooting section above
2. Review Terraform logs: `terraform apply -debug`
3. Check server setup log: `/var/log/evalpoint-setup.log`