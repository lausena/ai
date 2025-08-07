# Docker Private Registry Authentication

This guide shows how to authenticate your droplet with private Docker registries.

## Quick Setup

1. **Copy the auth script to your server:**
   ```bash
   scp infrastructure/docker-auth-setup.sh root@YOUR_SERVER_IP:/tmp/
   ```

2. **Run the interactive setup:**
   ```bash
   ssh root@YOUR_SERVER_IP
   chmod +x /tmp/docker-auth-setup.sh
   /tmp/docker-auth-setup.sh
   ```

## Manual Setup by Registry Type

### Docker Hub Private Repository

```bash
# On your droplet
docker login -u YOUR_USERNAME

# Enter your Docker Hub password or access token
# You can create access tokens at: https://hub.docker.com/settings/security
```

### DigitalOcean Container Registry

```bash
# Install doctl (DigitalOcean CLI)
cd /tmp
wget https://github.com/digitalocean/doctl/releases/download/v1.104.0/doctl-1.104.0-linux-amd64.tar.gz
tar xf doctl-1.104.0-linux-amd64.tar.gz
sudo mv doctl /usr/local/bin

# Authenticate with your DO API token
doctl auth init

# Login to registry
doctl registry login
```

### GitHub Container Registry

```bash
# Create a Personal Access Token with 'read:packages' permission
# at: https://github.com/settings/tokens

echo "YOUR_GITHUB_TOKEN" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### AWS ECR

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure

# Login to ECR (replace region and account ID)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
```

## Update Your Docker Compose

After authentication, update `/opt/evalpoint/docker-compose.yml`:

```yaml
version: '3.8'

services:
  web:
    # Replace with your actual private image
    image: your-registry/evalpoint:latest
    
    # Examples:
    # Docker Hub: username/evalpoint:latest
    # DigitalOcean: registry.digitalocean.com/your-registry/evalpoint:latest
    # GitHub: ghcr.io/username/evalpoint:latest
    # AWS ECR: 123456789.dkr.ecr.us-east-1.amazonaws.com/evalpoint:latest
    
    ports:
      - "8080:8080"
    environment:
      - PYTHONUNBUFFERED=1
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Deploy Your Application

```bash
cd /opt/evalpoint

# Pull and start your private image
./deploy.sh

# Check status
docker compose ps
docker compose logs
```

## Troubleshooting

### Authentication Issues
```bash
# Check if you're logged in
docker system info | grep -E 'Registry|Username'

# Test pulling your image manually
docker pull your-registry/evalpoint:latest

# Check logs
docker compose logs
```

### Permission Errors
```bash
# Make sure Docker daemon is running
sudo systemctl status docker

# Add user to docker group (if not using root)
sudo usermod -aG docker $USER
```

### Registry-Specific Issues

**Docker Hub:**
- Use access tokens instead of passwords for better security
- Create tokens at: https://hub.docker.com/settings/security

**DigitalOcean:**
- Make sure your API token has registry access
- Registry must be in the same region or globally accessible

**GitHub:**
- Personal Access Token needs `read:packages` permission
- Package must be public or you must have access

**AWS ECR:**
- ECR login tokens expire every 12 hours
- Consider using IAM roles for EC2 instances instead

## Automation

To automate registry login on server restart, add to your deploy script:

```bash
# Add to /opt/evalpoint/deploy.sh
echo "Authenticating with registry..."

# Example for Docker Hub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Or for DigitalOcean
doctl registry login

# Then pull and deploy
docker compose pull
docker compose up -d --remove-orphans
```

Store credentials securely using environment variables or Docker secrets for production deployments.