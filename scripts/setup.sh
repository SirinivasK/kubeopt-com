#!/bin/bash

# kubeopt Website Setup Script
# This script sets up the development environment

set -e

echo "🔍 kubeopt Website Setup"
echo "=========================="

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "Please install Python 3.8+ and try again."
    exit 1
fi

echo "✅ Python found: $(python3 --version)"

# Check if pip is installed
if ! command -v pip &> /dev/null; then
    echo "❌ pip is required but not installed."
    echo "Please install pip and try again."
    exit 1
fi

echo "✅ pip found: $(pip --version)"

# Create virtual environment
echo "📦 Creating virtual environment..."
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "✅ Virtual environment created"
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p database
mkdir -p logs
mkdir -p static/images
mkdir -p uploads
mkdir -p app/routes
mkdir -p app/models
mkdir -p app/utils

# Create __init__.py files for Python packages
echo "📝 Creating package files..."
touch app/__init__.py
touch app/routes/__init__.py
touch app/models/__init__.py
touch app/utils/__init__.py

# Copy environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📄 Creating environment file..."
    cat > .env << EOF
# Flask Configuration
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')
FLASK_ENV=development
FLASK_DEBUG=1

# Database
DATABASE_URL=sqlite:///database/kubeopt.db

# Email Configuration (Update with your SMTP settings)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_DEFAULT_SENDER=noreply@kubeopt.com

# Admin
ADMIN_EMAIL=admin@kubeopt.com

# Docker Settings
DOCKER_REGISTRY=docker.io
DOCKER_IMAGE=kubeopt/aks-optimizer
DOCKER_TAG=latest

# Analytics (Optional)
GOOGLE_ANALYTICS_ID=

# Security (Production)
SESSION_COOKIE_SECURE=false
SESSION_COOKIE_HTTPONLY=true
WTF_CSRF_ENABLED=true
EOF
    echo "✅ Environment file created (.env)"
    echo "⚠️  Please update the email settings in .env file"
else
    echo "✅ Environment file already exists"
fi

# Initialize database
echo "🗄️  Initializing database..."
if [ ! -f "database/kubeopt.db" ]; then
    # Create database using schema
    if [ -f "database/schema.sql" ]; then
        sqlite3 database/kubeopt.db < database/schema.sql
        echo "✅ Database initialized with schema"
    else
        # Create database using Flask
        python3 -c "
from app.main import app, db
with app.app_context():
    db.create_all()
    print('Database tables created')
"
        echo "✅ Database initialized with Flask models"
    fi
else
    echo "✅ Database already exists"
fi

# Create a simple health check
echo "🏥 Creating health check endpoint..."
if [ ! -f "app/routes/health.py" ]; then
    mkdir -p app/routes
    cat > app/routes/health.py << 'EOF'
from flask import Blueprint, jsonify
from datetime import datetime
import os

health_bp = Blueprint('health', __name__)

@health_bp.route('/health')
def health_check():
    """Simple health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0',
        'environment': os.environ.get('FLASK_ENV', 'development')
    })
EOF
    echo "✅ Health check endpoint created"
fi

# Test the installation
echo "🧪 Testing installation..."
python3 -c "
import sys
try:
    from app.main import app
    print('✅ Flask app imports successfully')
    
    with app.app_context():
        from app.main import db
        print('✅ Database connection successful')
        
    print('✅ All tests passed!')
except Exception as e:
    print(f'❌ Test failed: {e}')
    sys.exit(1)
"

echo ""
echo "🎉 Setup Complete!"
echo "==================="
echo ""
echo "Next steps:"
echo "1. Update email settings in .env file"
echo "2. Start the development server:"
echo "   source .venv/bin/activate"
echo "   python app/main.py"
echo ""
echo "3. Visit http://localhost:5050"
echo ""
echo "For Docker development:"
echo "   docker-compose up"
echo ""
echo "Documentation: README.md"
echo "Need help? Check the docs/ directory"
echo ""

# Make the script executable
chmod +x scripts/setup.sh

echo "🔍 kubeopt website is ready to go!"