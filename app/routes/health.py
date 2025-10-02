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
