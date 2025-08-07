# Rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;

# Upstream for the Flask application
upstream evalpoint_app {
    server 127.0.0.1:8080;
    keepalive 32;
}

# Redirect HTTP to HTTPS (will be activated after SSL is set up)
server {
    listen 80;
    server_name ${domain_name} www.${domain_name};
    
    # Allow Let's Encrypt challenges
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    # Redirect all other HTTP traffic to HTTPS (uncomment after SSL setup)
    # return 301 https://$server_name$request_uri;
    
    # Temporary: serve the application directly over HTTP
    location / {
        # Rate limiting
        limit_req zone=api burst=20 nodelay;
        
        # Proxy settings
        proxy_pass http://evalpoint_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Static files (served directly by nginx for better performance)
    location /static/ {
        alias /opt/evalpoint/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options nosniff;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://evalpoint_app;
    }
}

# HTTPS server (will be configured by Certbot)
server {
    listen 443 ssl http2;
    server_name ${domain_name} www.${domain_name};
    
    # SSL configuration (will be added by Certbot)
    # ssl_certificate /etc/letsencrypt/live/${domain_name}/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/${domain_name}/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
    
    location / {
        # Rate limiting
        limit_req zone=api burst=20 nodelay;
        
        # Proxy settings
        proxy_pass http://evalpoint_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Static files
    location /static/ {
        alias /opt/evalpoint/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options nosniff;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://evalpoint_app;
    }
    
    # Security: deny access to hidden files
    location ~ /\. {
        deny all;
    }
}