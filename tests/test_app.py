import pytest
from app import create_app


@pytest.fixture
def app():
    """Create and configure a test app."""
    app = create_app()
    app.config['TESTING'] = True
    return app


@pytest.fixture
def client(app):
    """Create a test client for the Flask application."""
    return app.test_client()


def test_home_page(client):
    """Test home page loads correctly."""
    response = client.get('/')
    assert response.status_code == 200
    assert b'Build AI That Lasts' in response.data
    assert b'EvalPoint' in response.data


def test_about_page(client):
    """Test about page loads correctly."""
    response = client.get('/about')
    assert response.status_code == 200
    assert b'Gabriel Sena' in response.data
    assert b'Why I Built EvalPoint' in response.data


def test_services_page(client):
    """Test services page loads correctly."""
    response = client.get('/services')
    assert response.status_code == 200
    assert b'AI Integration Strategy' in response.data
    assert b'System Design Reviews' in response.data
    assert b'Internal Enablement' in response.data


def test_strategy_call_page(client):
    """Test strategy call page loads correctly."""
    response = client.get('/strategy-call')
    assert response.status_code == 200
    assert b'AI Strategy Session' in response.data
    assert b'$129' in response.data


def test_contact_page(client):
    """Test contact page loads correctly."""
    response = client.get('/contact')
    assert response.status_code == 200
    assert b'Get in Touch' in response.data
    assert b'gabriel@evalpoint.ai' in response.data


def test_404_error(client):
    """Test 404 error handling."""
    response = client.get('/nonexistent-page')
    assert response.status_code == 404


def test_navigation_links(client):
    """Test that all navigation links are present on home page."""
    response = client.get('/')
    assert response.status_code == 200
    
    # Check for navigation links
    assert b'href="/"' in response.data  # Home link
    assert b'href="/about"' in response.data  # About link
    assert b'href="/services"' in response.data  # Services link
    assert b'href="/strategy-call"' in response.data  # Strategy Call link
    assert b'href="/contact"' in response.data  # Contact link


def test_css_and_js_links(client):
    """Test that CSS and JS files are linked correctly."""
    response = client.get('/')
    assert response.status_code == 200
    
    # Check for CSS link
    assert b'href="/static/css/style.css"' in response.data
    
    # Check for JS link
    assert b'src="/static/js/main.js"' in response.data


def test_responsive_meta_tag(client):
    """Test that viewport meta tag is present for mobile responsiveness."""
    response = client.get('/')
    assert response.status_code == 200
    assert b'name="viewport"' in response.data
    assert b'width=device-width, initial-scale=1.0' in response.data


def test_google_fonts_link(client):
    """Test that Google Fonts are loaded."""
    response = client.get('/')
    assert response.status_code == 200
    assert b'fonts.googleapis.com' in response.data
    assert b'Inter' in response.data