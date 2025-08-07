#!/bin/bash

# EvalPoint Post-Deployment Setup Script
# Run this on your droplet after Terraform deployment to complete the setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for user input
wait_for_user() {
    read -p "Press Enter to continue or Ctrl+C to cancel..."
}

echo "==============================================="
echo "  EvalPoint Post-Deployment Setup"
echo "==============================================="
echo ""

# Check if we're on the right server
if [[ ! -f "/opt/evalpoint/docker-compose.yml" ]]; then
    log_error "This doesn't appear to be an EvalPoint server."
    log_info "Please ensure you're running this on the correct droplet."
    exit 1
fi

# 1. Application Setup
log_info "Setting up EvalPoint application directory..."
cd /opt/evalpoint

# Check if docker-compose.yml exists and is configured
if grep -q "image: evalpoint:latest" docker-compose.yml; then
    log_warning "Docker Compose is using local image. You need to:"
    log_info "1. Build and push your image to a registry, OR"
    log_info "2. Copy your application code to the server"
    echo ""
    echo "Choose your deployment method:"
    echo "1) Use Docker registry (recommended)"
    echo "2) Build locally on server"
    read -p "Enter your choice (1-2): " deploy_method
    
    case $deploy_method in
        1)
            log_info "Please update docker-compose.yml with your registry image:"
            log_info "  image: your-registry/evalpoint:latest"
            wait_for_user
            ;;
        2)
            log_info "Building image locally on server..."
            if [[ -d "app" ]]; then
                cd app && docker build -t evalpoint . && cd ..
                log_success "Image built successfully"
            else
                log_error "No app directory found. Please copy your source code here first."
                exit 1
            fi
            ;;
    esac
fi

# 2. Registry Authentication (if needed)
log_info "Setting up Docker registry authentication..."
echo "Do you need to authenticate with a private Docker registry?"
echo "1) Yes - Docker Hub"
echo "2) Yes - DigitalOcean Container Registry" 
echo "3) Yes - GitHub Container Registry"
echo "4) No - using public registry or local images"
read -p "Enter your choice (1-4): " auth_choice

case $auth_choice in
    1)
        log_info "Docker Hub authentication..."
        read -p "Docker Hub username: " docker_username
        read -s -p "Docker Hub password/token: " docker_password
        echo ""
        echo "$docker_password" | docker login -u "$docker_username" --password-stdin
        ;;
    2)
        log_info "DigitalOcean Container Registry authentication..."
        if ! command_exists doctl; then
            log_info "Installing doctl..."
            cd /tmp
            wget https://github.com/digitalocean/doctl/releases/download/v1.104.0/doctl-1.104.0-linux-amd64.tar.gz
            tar xf doctl-1.104.0-linux-amd64.tar.gz
            sudo mv doctl /usr/local/bin
            cd -
        fi
        read -p "DigitalOcean API Token: " do_token
        doctl auth init -t "$do_token"
        doctl registry login
        ;;
    3)
        log_info "GitHub Container Registry authentication..."
        read -p "GitHub username: " gh_username
        read -s -p "GitHub Personal Access Token: " gh_token
        echo ""
        echo "$gh_token" | docker login ghcr.io -u "$gh_username" --password-stdin
        ;;
    4)
        log_info "Skipping registry authentication"
        ;;
esac

# 3. Deploy Application
log_info "Deploying EvalPoint application..."
docker compose down 2>/dev/null || true
docker compose pull
docker compose up -d

# Wait for app to start
log_info "Waiting for application to start..."
sleep 10

# Test application
if curl -f http://localhost:8080/ >/dev/null 2>&1; then
    log_success "Application is running!"
else
    log_error "Application failed to start. Check logs:"
    docker compose logs
    exit 1
fi

# 4. SSL Certificate Setup
log_info "Setting up SSL certificates..."
read -p "Enter your domain name (or press Enter to skip SSL setup): " domain_name

if [[ -n "$domain_name" ]]; then
    # Check if domain points to this server
    domain_ip=$(dig +short "$domain_name")
    server_ip=$(curl -s ifconfig.me)
    
    if [[ "$domain_ip" == "$server_ip" ]]; then
        log_success "Domain correctly points to this server ($server_ip)"
        
        # Ensure nginx is running
        if ! systemctl is-active --quiet nginx; then
            log_info "Starting nginx..."
            systemctl start nginx
        fi
        
        # Get SSL certificate
        log_info "Obtaining SSL certificate for $domain_name..."
        certbot --nginx -d "$domain_name" -d "www.$domain_name" \
                --non-interactive --agree-tos --email "admin@$domain_name"
        
        if [[ $? -eq 0 ]]; then
            log_success "SSL certificate installed successfully!"
            
            # Set up automatic renewal
            (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
            log_success "Automatic certificate renewal configured"
            
            log_info "Your site is available at:"
            log_info "  https://$domain_name"
            log_info "  https://www.$domain_name"
        else
            log_error "SSL certificate installation failed"
            log_info "You can try again later with: certbot --nginx -d $domain_name -d www.$domain_name"
        fi
    else
        log_error "Domain $domain_name does not point to this server"
        log_info "Current domain IP: $domain_ip"
        log_info "This server IP: $server_ip"
        log_info "Please update your DNS records and try again"
    fi
else
    log_info "Skipping SSL setup"
fi

# 5. Final Health Check
log_info "Performing final health checks..."

# Check services
services_ok=true

if systemctl is-active --quiet docker; then
    log_success "Docker is running"
else
    log_error "Docker is not running"
    services_ok=false
fi

if systemctl is-active --quiet nginx; then
    log_success "Nginx is running"
else
    log_error "Nginx is not running"
    services_ok=false
fi

if docker compose ps | grep -q "Up"; then
    log_success "EvalPoint application is running"
else
    log_error "EvalPoint application is not running"
    services_ok=false
fi

# Check connectivity
if curl -f http://localhost:8080/health >/dev/null 2>&1; then
    log_success "Application health check passed"
else
    log_warning "Application health check failed (this may be normal if /health endpoint doesn't exist)"
fi

# Check firewall
if ufw status | grep -q "Status: active"; then
    log_success "Firewall is active"
    if ufw status | grep -q "80\|443\|Nginx"; then
        log_success "HTTP/HTTPS ports are open"
    else
        log_warning "HTTP/HTTPS ports may not be open in firewall"
    fi
else
    log_warning "UFW firewall is not active"
fi

echo ""
echo "==============================================="
if $services_ok; then
    log_success "Setup completed successfully!"
else
    log_error "Setup completed with some issues"
fi
echo "==============================================="
echo ""

log_info "Useful commands:"
echo "  • View application logs: docker compose logs -f"
echo "  • Restart application: docker compose restart"
echo "  • Update application: ./deploy.sh"
echo "  • Check nginx config: nginx -t"
echo "  • View system status: systemctl status nginx docker"
echo ""

if [[ -n "$domain_name" ]]; then
    log_info "Access your application at:"
    if [[ -f "/etc/letsencrypt/live/$domain_name/fullchain.pem" ]]; then
        echo "  • https://$domain_name"
        echo "  • https://www.$domain_name"
    else
        echo "  • http://$domain_name"
        echo "  • http://www.$domain_name"
    fi
else
    server_ip=$(curl -s ifconfig.me)
    log_info "Access your application at:"
    echo "  • http://$server_ip:8080 (direct)"
    echo "  • http://$server_ip (via nginx)"
fi

echo ""
log_info "Setup log saved to: /var/log/evalpoint-setup.log"