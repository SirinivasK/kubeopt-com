from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os
import sys
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3

# Add parent directory to path to import config
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Get the base directory
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
DATABASE_DIR = os.path.join(BASE_DIR, 'database')
DATABASE_FILE = os.path.join(DATABASE_DIR, 'kubeopt.db')

# Create necessary directories immediately
os.makedirs(DATABASE_DIR, exist_ok=True)
os.makedirs(os.path.join(BASE_DIR, 'logs'), exist_ok=True)
os.makedirs(os.path.join(BASE_DIR, 'app', 'static', 'images'), exist_ok=True)

# Create the database file if it doesn't exist (BEFORE Flask/SQLAlchemy initialization)
if not os.path.exists(DATABASE_FILE):
    print(f"📝 Creating database file: {DATABASE_FILE}")
    try:
        # Create an empty SQLite database
        conn = sqlite3.connect(DATABASE_FILE)
        conn.close()
        print(f"✅ Database file created successfully")
    except Exception as e:
        print(f"❌ Failed to create database file: {e}")
        sys.exit(1)

# Initialize Flask app
app = Flask(__name__)

# Configuration - Use forward slashes for SQLite URI
DATABASE_URI = f'sqlite:///{DATABASE_FILE.replace(os.sep, "/")}'

app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', DATABASE_URI)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAIL_SERVER'] = os.environ.get('MAIL_SERVER', 'smtp.gmail.com')
app.config['MAIL_PORT'] = int(os.environ.get('MAIL_PORT', 587))
app.config['MAIL_USE_TLS'] = os.environ.get('MAIL_USE_TLS', 'true').lower() in ['true', 'on', '1']
app.config['MAIL_USERNAME'] = os.environ.get('MAIL_USERNAME')
app.config['MAIL_PASSWORD'] = os.environ.get('MAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.environ.get('MAIL_DEFAULT_SENDER', 'noreply@kubeopt.com')
app.config['ADMIN_EMAIL'] = os.environ.get('ADMIN_EMAIL', 'admin@kubeopt.com')

print(f"🔍 Database URI: {app.config['SQLALCHEMY_DATABASE_URI']}")

# Database setup - NOW the database file exists
db = SQLAlchemy(app)

# Context processor for templates
@app.context_processor
def inject_globals():
    """Inject global variables into all templates"""
    return {
        'current_year': datetime.now().year,
        'app_name': 'kubeopt'
    }

# Models
class Contact(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    company = db.Column(db.String(100))
    message = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.String(20), default='new')

class PageView(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    page = db.Column(db.String(100), nullable=False)
    ip_address = db.Column(db.String(45))
    user_agent = db.Column(db.String(200))
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

class Download(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), nullable=False)
    version = db.Column(db.String(20), default='latest')
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

# Routes
@app.route('/')
def index():
    # Track page view
    track_page_view('home')
    return render_template('index.html')

# Redirect all menu items to main page with anchor links
@app.route('/features')
def features():
    track_page_view('features')
    return redirect(url_for('index') + '#features')

@app.route('/pricing')
def pricing():
    track_page_view('pricing')
    return redirect(url_for('index') + '#pricing')

@app.route('/docs')
def docs():
    track_page_view('docs')
    return redirect(url_for('index') + '#docs')

@app.route('/contact', methods=['GET', 'POST'])
def contact():
    if request.method == 'POST':
        # Handle contact form submission
        contact = Contact(
            name=request.form.get('name'),
            email=request.form.get('email'),
            company=request.form.get('company'),
            message=request.form.get('message')
        )
        db.session.add(contact)
        db.session.commit()
        
        flash('Thank you for your message! We\'ll get back to you soon.', 'success')
        return redirect(url_for('index') + '#contact')
    
    track_page_view('contact')
    return redirect(url_for('index') + '#contact')

@app.route('/download')
def download():
    track_page_view('download')
    return redirect(url_for('index') + '#download')

# API Routes
@app.route('/api/stats')
def api_stats():
    """API endpoint for dashboard statistics"""
    stats = {
        'total_downloads': Download.query.count(),
        'total_contacts': Contact.query.count(),
        'monthly_views': get_monthly_views(),
        'popular_pages': get_popular_pages()
    }
    return jsonify(stats)

@app.route('/api/download', methods=['POST'])
def api_download():
    """Handle download tracking"""
    email = request.json.get('email')
    if email:
        download = Download(email=email)
        db.session.add(download)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'download_url': 'docker pull kubeopt/aks-optimizer:latest',
            'instructions': 'Check your email for installation instructions'
        })
    
    return jsonify({'success': False, 'error': 'Email required'}), 400

@app.route('/api/analytics/pageview', methods=['POST'])
def api_analytics_pageview():
    """Track page views"""
    try:
        data = request.get_json() or {}
        page = data.get('page', request.referrer or '/')
        track_page_view(page)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/analytics/event', methods=['POST'])
def api_analytics_event():
    """Track events"""
    try:
        data = request.get_json() or {}
        action = data.get('action', 'unknown')
        label = data.get('label', '')
        
        # Simple event tracking - you can enhance this with a proper Event model
        # For now, we'll just return success to prevent console errors
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/demo-data')
def api_demo_data():
    """Return demo data for charts"""
    demo_data = {
        'cost_trends': {
            'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            'current': [12500, 13200, 12800, 14100, 13800, 8420],
            'optimized': [8200, 8400, 8100, 8800, 8600, 5240]
        },
        'utilization': {
            'labels': ['CPU', 'Memory', 'Storage', 'Network'],
            'current': [45, 78, 34, 56],
            'optimized': [65, 85, 52, 71]
        },
        'efficiency': {
            'labels': ['Efficient', 'Over-provisioned', 'Under-provisioned'],
            'data': [67, 23, 10]
        },
        'savings': {
            'labels': ['Right-sizing', 'Auto-scaling', 'Node Optimization', 'Storage'],
            'data': [1200, 850, 890, 240]
        }
    }
    return jsonify(demo_data)

# Health endpoint for Kubernetes
@app.route('/health')
def health_check():
    """Health check endpoint for Kubernetes probes"""
    try:
        # Test database connection
        db.session.execute('SELECT 1')
        return jsonify({
            'status': 'healthy',
            'service': 'kubeopt-com',
            'version': '1.0.0',
            'timestamp': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 503

# Admin Routes (basic)
@app.route('/admin')
def admin_dashboard():
    """Simple admin dashboard"""
    contacts = Contact.query.order_by(Contact.created_at.desc()).limit(10).all()
    stats = {
        'total_contacts': Contact.query.count(),
        'total_downloads': Download.query.count(),
        'total_views': PageView.query.count()
    }
    return render_template('admin/dashboard.html', contacts=contacts, stats=stats)

# Utility functions
def track_page_view(page):
    """Track page views for analytics"""
    try:
        page_view = PageView(
            page=page,
            ip_address=request.remote_addr,
            user_agent=request.headers.get('User-Agent', '')[:200]
        )
        db.session.add(page_view)
        db.session.commit()
    except Exception as e:
        print(f"Error tracking page view: {e}")

def get_monthly_views():
    """Get monthly page views"""
    # Simple implementation - you can enhance this
    return PageView.query.filter(
        PageView.timestamp >= datetime.now().replace(day=1)
    ).count()

def get_popular_pages():
    """Get most popular pages"""
    # Simple implementation
    result = db.session.execute(
        "SELECT page, COUNT(*) as views FROM page_view GROUP BY page ORDER BY views DESC LIMIT 5"
    ).fetchall()
    return [{'page': row[0], 'views': row[1]} for row in result]

if __name__ == '__main__':
    print("=" * 60)
    print("🔍 kubeopt Website")
    print("=" * 60)
    print(f"📁 Database: {DATABASE_FILE}")
    print(f"📁 File exists: {os.path.exists(DATABASE_FILE)}")
    
    # Create tables
    print("🗄️  Creating database tables...")
    with app.app_context():
        try:
            db.create_all()
            print("✅ Database tables ready!")
        except Exception as e:
            print(f"❌ Database error: {e}")
            print(f"💡 Tip: Try running with FLASK_DEBUG=0 to disable reloader")
            import traceback
            traceback.print_exc()
            sys.exit(1)
    
    print("=" * 60)
    print("🚀 Server: http://localhost:5050")
    print("📍 Press CTRL+C to stop")
    print("=" * 60)
    
    # Run without debugger reloader to avoid path issues
    app.run(host='0.0.0.0', port=5050, debug=True, use_reloader=False)