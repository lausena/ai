# AI Project

A simple Flask web application.

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

## Running the Project

### Development Server

```bash
uv run python -m src.app
```

The application will start on `http://localhost:8080`

### Available Endpoints

- `/` - AI Consulting homepage
- `/about` - About the consultant
- `/services` - AI integration services
- `/contact` - Contact and booking information
- `/health` - Health check endpoint

## Deployment

### Production Server

For production deployment, use Gunicorn as the WSGI server:

```bash
# Install dependencies including Gunicorn
uv sync

# Run with Gunicorn
uv run gunicorn --bind 0.0.0.0:8080 wsgi:app
```

### Docker Deployment

To deploy using Docker on Ubuntu:

```bash
# Clone the repository
git clone <your-repo-url>
cd ai

# Build the Docker image
docker build -t ai-app .

# Run the container
docker run -d -p 8080:8080 --name ai-app ai-app

# Or use docker-compose (create docker-compose.yml first)
docker-compose up -d
```

### Web Server Configuration

Configure your web server (nginx, Apache, etc.) to proxy requests to the application running on port 8080.

Example nginx configuration:
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
}
```

## Project Structure

- `main.py` - Main Flask application
- `wsgi.py` - WSGI entry point for production deployment
- `pyproject.toml` - Project configuration and dependencies
- `uv.lock` - Locked dependency versions


## Adding MCP Servers
#### Fetch
claude mcp add http-fetch -- uvx mcp-server-fetch
