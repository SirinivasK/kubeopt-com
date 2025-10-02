import os
from datetime import timedelta

class Config:
    """Application configuration"""
    
    # Basic Flask config
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # Database
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///database/kubeopt.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Email configuration (for contact form)
    MAIL_SERVER = os.environ.get('MAIL_SERVER') or 'smtp.gmail.com'
    MAIL_PORT = int(os.environ.get('MAIL_PORT') or 587)
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS', 'true').lower() in ['true', 'on', '1']
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    MAIL_DEFAULT_SENDER = os.environ.get('MAIL_DEFAULT_SENDER') or 'noreply@kubeopt.com'
    
    # Admin settings
    ADMIN_EMAIL = os.environ.get('ADMIN_EMAIL') or 'admin@kubeopt.com'
    
    # Application settings
    ITEMS_PER_PAGE = 20
    SESSION_PERMANENT = True
    PERMANENT_SESSION_LIFETIME = timedelta(hours=24)
    
    # Security
    WTF_CSRF_ENABLED = True
    WTF_CSRF_TIME_LIMIT = 3600
    
    # Docker registry settings (for download instructions)
    DOCKER_REGISTRY = os.environ.get('DOCKER_REGISTRY') or 'docker.io'
    DOCKER_IMAGE = os.environ.get('DOCKER_IMAGE') or 'kubeopt/aks-optimizer'
    DOCKER_TAG = os.environ.get('DOCKER_TAG') or 'latest'
    
    # Analytics
    GOOGLE_ANALYTICS_ID = os.environ.get('GOOGLE_ANALYTICS_ID')
    
    @property
    def docker_pull_command(self):
        return f"docker pull {self.DOCKER_REGISTRY}/{self.DOCKER_IMAGE}:{self.DOCKER_TAG}"

class DevelopmentConfig(Config):
    """Development configuration"""
    DEBUG = True
    SQLALCHEMY_ECHO = False  # Set to True to see SQL queries

class ProductionConfig(Config):
    """Production configuration"""
    DEBUG = False
    
    # Use stronger session protection in production
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'

class TestingConfig(Config):
    """Testing configuration"""
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    WTF_CSRF_ENABLED = False

# Configuration dictionary
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}