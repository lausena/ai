#!/bin/bash

# Update system packages
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

# Install essential packages
apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    fail2ban \
    htop \
    vim

# Configure UFW firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 'Nginx Full'
ufw allow 8080
ufw --force enable

# Configure fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Install Nginx
apt-get install -y nginx

# Remove default Nginx configuration
rm -f /etc/nginx/sites-enabled/default

# Create Nginx configuration for EvalPoint
echo "${nginx_config_content}" | base64 -d > /etc/nginx/sites-available/evalpoint
ln -s /etc/nginx/sites-available/evalpoint /etc/nginx/sites-enabled/

# Test and start Nginx
nginx -t
systemctl start nginx
systemctl enable nginx

# Create application directory
mkdir -p /opt/evalpoint
cd /opt/evalpoint

# Clone the repository (you'll need to update this with your actual repo)
# For now, we'll create the docker-compose file directly
echo "${docker_compose_content}" | base64 -d > docker-compose.yml

# Create a simple deployment script
cat > /opt/evalpoint/deploy.sh << 'EOF'
#!/bin/bash

# Pull latest changes (uncomment when you have a git repo)
# git pull origin main

# Pull latest Docker images and restart services
docker compose pull
docker compose up -d --remove-orphans

# Clean up unused images
docker image prune -af

echo "Deployment completed at $(date)"
EOF

chmod +x /opt/evalpoint/deploy.sh

# Create a systemd service for the app (optional, for auto-start on boot)
cat > /etc/systemd/system/evalpoint.service << EOF
[Unit]
Description=EvalPoint Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/evalpoint
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl daemon-reload
systemctl enable evalpoint.service

# Create SSL certificate directory (for Let's Encrypt later)
mkdir -p /etc/letsencrypt/live
mkdir -p /var/log/letsencrypt

# Install Certbot for SSL certificates
apt-get install -y certbot python3-certbot-nginx

# Create a script for SSL setup
cat > /opt/evalpoint/setup-ssl.sh << 'EOF'
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <domain-name>"
    exit 1
fi

DOMAIN=$1

# Obtain SSL certificate
certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

# Set up automatic renewal
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

echo "SSL certificate setup completed for $DOMAIN"
EOF

chmod +x /opt/evalpoint/setup-ssl.sh

# Set up log rotation for Docker containers
cat > /etc/logrotate.d/docker-container << EOF
/var/lib/docker/containers/*/*.log {
  rotate 5
  daily
  compress
  size 10M
  missingok
  delaycompress
  copytruncate
}
EOF

# Create monitoring script
cat > /opt/evalpoint/monitor.sh << 'EOF'
#!/bin/bash

# Simple health check script
APP_URL="http://localhost:8080"
EMAIL="admin@example.com"  # Update this

if ! curl -f $APP_URL > /dev/null 2>&1; then
    echo "EvalPoint application is down!" | mail -s "EvalPoint Alert" $EMAIL
    # Attempt to restart
    cd /opt/evalpoint && docker compose restart
fi
EOF

chmod +x /opt/evalpoint/monitor.sh

# Add to crontab for monitoring (every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * /opt/evalpoint/monitor.sh") | crontab -

# Start the application
cd /opt/evalpoint
# We can't start Docker Compose here because we don't have the actual image yet
# This will need to be done after the image is built and pushed

# Create a welcome message
cat > /etc/motd << EOF

╔══════════════════════════════════════════════╗
║              EvalPoint Server                ║
║            Ubuntu 25.04 LTS                  ║
╠══════════════════════════════════════════════╣
║ Application Directory: /opt/evalpoint        ║
║ Nginx Config: /etc/nginx/sites-available/    ║
║ SSL Setup: /opt/evalpoint/setup-ssl.sh       ║
║ Deploy: /opt/evalpoint/deploy.sh             ║
╚══════════════════════════════════════════════╝

EOF

# Log completion
echo "Server setup completed at $(date)" >> /var/log/setup.log

# Reboot to ensure all services start properly
shutdown -r +1 "Server setup complete, rebooting in 1 minute"