# EvalPoint - Build AI That Lasts

A professional Flask web application for EvalPoint, showcasing AI strategy and integration services with a futuristic design.

## Features

- **Responsive Design**: Mobile-first approach with futuristic styling
- **Modern UI**: Uses graphite gray, steel blue, brushed silver, electric cyan, and neon lime color palette
- **Professional Pages**: Home, About, Services, Strategy Call booking, and Contact pages
- **Testing Suite**: Comprehensive pytest test coverage
- **Production Ready**: Configured for deployment with Gunicorn

## Installation

This project uses [uv](https://docs.astral.sh/uv/) for Python package management.

### Install UV

```bash
# On macOS and Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# On Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### Install Dependencies

```bash
uv sync
```

## Development

### Run Development Server

```bash
# Basic development server (runs on port 8080)
uv run python app.py

# With custom port
uv run python app.py --port 3000

# With debug mode
uv run python app.py --debug
```

### Run Tests

```bash
# Run all tests
uv run pytest

# Run tests with verbose output
uv run pytest -v

# Run specific test file
uv run pytest tests/test_app.py
```

### Project Structure

```
├── app.py                 # Main Flask application
├── wsgi.py               # WSGI entry point for production
├── gunicorn_config.py    # Gunicorn configuration
├── pyproject.toml        # Project dependencies and config
├── templates/            # Jinja2 templates
│   ├── base.html        # Base template
│   ├── home.html        # Homepage
│   ├── about.html       # About page
│   ├── services.html    # Services page
│   ├── strategy_call.html # Strategy call booking
│   └── contact.html     # Contact page
├── static/              # Static assets
│   ├── css/
│   │   └── style.css    # Main stylesheet
│   └── js/
│       └── main.js      # JavaScript functionality
└── tests/               # Test suite
    └── test_app.py      # Application tests
```

## Production Deployment

### Local Production Server

```bash
# Using Gunicorn with configuration file
uv run gunicorn --config gunicorn_config.py wsgi:app

# Manual Gunicorn configuration
uv run gunicorn --bind 0.0.0.0:8080 --workers 2 wsgi:app
```

### Digital Ocean App Platform

1. Push your code to GitHub
2. Connect your GitHub repository to Digital Ocean App Platform
3. Configure the build command:
   ```bash
   # No build command needed, uv will handle dependencies
   ```
4. Configure the run command:
   ```bash
   gunicorn --worker-tmp-dir /dev/shm --config gunicorn_config.py wsgi:app
   ```

### Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM python:3.13-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-cache

# Copy application code
COPY . .

# Expose port
EXPOSE 8080

# Run the application
CMD ["uv", "run", "gunicorn", "--config", "gunicorn_config.py", "wsgi:app"]
```

Build and run:
```bash
# Build the image
docker build --platform linux/amd64 -t evalpoint .

# Or use Docker Compose
docker compose up -d
```

Deploy to Docker registry:
```
docker tag evalpoint gxlaus/evalpoint:latest 

docker push gxlaus/evalpoint:latest 
```

### Nginx Configuration

Example nginx configuration for reverse proxy:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static {
        alias /path/to/your/app/static;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

## Available Pages

- **/** - Homepage with EvalPoint branding and value proposition
- **/about** - Gabriel Sena's background and experience
- **/services** - AI integration services and methodology  
- **/strategy-call** - Strategy session booking with pricing
- **/contact** - Contact information and social media links

## Design Features

- **Futuristic Theme**: Professional look with metallic and neon accents
- **Mobile-First**: Responsive design that works on all devices
- **Performance**: Optimized CSS with smooth animations and hover effects
- **Accessibility**: High contrast colors and readable typography
- **Modern Fonts**: Uses Inter font family from Google Fonts

## Testing

The application includes comprehensive tests covering:

- Page rendering and content
- Navigation functionality
- Responsive design elements
- Error handling
- Static asset loading

## Environment Variables

No environment variables are required for basic operation. The application uses sensible defaults for development and production.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `uv run pytest`
5. Submit a pull request

## License

Private project for EvalPoint services.