# kubeopt.com Website

A professional marketing and information website for the kubeopt AKS cost optimization tool. This Flask-based website showcases your containerized ML-driven Kubernetes optimizer.

## 🚀 Features

- **Modern Dark Blue Theme** - Professional and technical aesthetic
- **Interactive Dashboard Previews** - Live charts showing optimization capabilities
- **Container-First Messaging** - Emphasizes security and on-premise deployment
- **Contact Forms & Analytics** - Lead capture and basic visitor tracking
- **Mobile Responsive** - Optimized for all device sizes
- **SEO Optimized** - Proper meta tags and structure
- **Fast & Lightweight** - Optimized performance

## 🛠 Tech Stack

- **Backend**: Flask (Python)
- **Database**: SQLite (easily upgradeable to PostgreSQL)
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Charts**: Chart.js for interactive visualizations
- **Deployment**: Docker & Docker Compose ready
- **Server**: Gunicorn for production

## 📁 Project Structure

```
kubeopt-website/
├── app/                    # Flask application
│   ├── main.py            # Main application file
│   ├── config.py          # Configuration
│   ├── routes/            # Route handlers
│   ├── models/            # Database models
│   ├── static/            # CSS, JS, images
│   ├── templates/         # Jinja2 templates
│   └── utils/             # Helper functions
├── database/              # Database files & schema
├── scripts/               # Setup & deployment scripts
├── tests/                 # Test files
└── docs/                  # Documentation
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url> kubeopt-website
cd kubeopt-website

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate    # Windows

# Install dependencies
pip install -r requirements.txt
```

### 2. Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your settings
nano .env
```

Required environment variables:
```bash
SECRET_KEY=your-secret-key-here
MAIL_USERNAME=your-smtp-username
MAIL_PASSWORD=your-smtp-password
ADMIN_EMAIL=admin@kubeopt.com
```

### 3. Initialize Database

```bash
# Run database setup
python -c "from app.main import app, db; app.app_context().push(); db.create_all()"

# Or use the schema file directly
sqlite3 database/kubeopt.db < database/schema.sql
```

### 4. Run Development Server

```bash
# Method 1: Direct Flask
python app/main.py

# Method 2: Flask CLI
export FLASK_APP=app/main.py
flask run

# Method 3: Docker Compose
docker-compose up
```

Visit `http://localhost:5000` to see your website!

## 🐳 Docker Deployment

### Development with Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f web

# Stop services
docker-compose down
```

### Production Docker Build

```bash
# Build image
docker build -t kubeopt-website .

# Run container
docker run -d \
  --name kubeopt-web \
  -p 5000:5000 \
  -e SECRET_KEY=your-secret \
  -e FLASK_ENV=production \
  kubeopt-website
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRET_KEY` | Flask secret key | `dev-secret-key` |
| `DATABASE_URL` | Database connection | `sqlite:///database/kubeopt.db` |
| `MAIL_SERVER` | SMTP server | `smtp.gmail.com` |
| `MAIL_USERNAME` | SMTP username | None |
| `MAIL_PASSWORD` | SMTP password | None |
| `ADMIN_EMAIL` | Admin email | `admin@kubeopt.com` |
| `DOCKER_IMAGE` | Docker image name | `kubeopt/aks-optimizer` |
| `GOOGLE_ANALYTICS_ID` | GA tracking ID | None |

### Flask Configuration

Edit `config.py` to modify:
- Database settings
- Email configuration  
- Security settings
- Docker registry details

## 📊 Dashboard Features

The website includes interactive dashboard previews that simulate your actual tool:

- **Cost Trends Chart** - Shows current vs optimized costs
- **Resource Utilization** - CPU, Memory, Storage, Network usage
- **Node Efficiency** - Efficiency scoring with ML confidence
- **Savings Breakdown** - Categorized monthly savings projections

## 📨 Contact Form & Analytics

### Contact Form
- Captures leads with company information
- Email notifications to admin
- Status tracking (new, in_progress, resolved)

### Basic Analytics
- Page view tracking
- Download tracking  
- Event tracking (button clicks, form submissions)
- Simple dashboard in `/admin`

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/stats` | GET | Website statistics |
| `/api/download` | POST | Track downloads |
| `/api/demo-data` | GET | Chart demo data |
| `/api/newsletter` | POST | Newsletter signup |

## 🎨 Customization

### Styling
- Edit `static/css/main.css` for theme changes
- CSS custom properties in `:root` for easy color updates
- Component-based CSS in `static/css/components.css`

### Content
- Update templates in `templates/`
- Modify demo data in `/api/demo-data` endpoint
- Change pricing in `templates/pricing.html`

### Branding
- Replace logo in `static/images/`
- Update social links in `templates/base.html`
- Modify meta tags and titles

## 🚀 Deployment Options

### 1. Traditional Hosting (VPS/Dedicated)
```bash
# Clone repo on server
git clone <your-repo> /var/www/kubeopt
cd /var/www/kubeopt

# Setup production environment
pip install -r requirements.txt
cp .env.example .env
# Edit .env with production values

# Run with Gunicorn
gunicorn --bind 0.0.0.0:5000 --workers 4 app.main:app
```

### 2. Docker Production
```bash
# Build and deploy
docker build -t kubeopt-website .
docker run -d --name kubeopt-web -p 80:5000 kubeopt-website
```

### 3. Cloud Platforms
- **Heroku**: Include `Procfile` with `web: gunicorn app.main:app`
- **Railway**: Direct deploy from GitHub
- **DigitalOcean App Platform**: Use `app.yaml` config
- **AWS ECS**: Use provided Dockerfile

## 📈 Monitoring & Maintenance

### Health Check
Visit `/health` endpoint to verify application status.

### Database Maintenance
```bash
# Backup database
cp database/kubeopt.db database/backup-$(date +%Y%m%d).db

# Clean old analytics data (optional)
sqlite3 database/kubeopt.db "DELETE FROM page_view WHERE timestamp < date('now', '-90 days');"
```

### Log Management
- Application logs in `logs/` directory
- Configure log rotation for production
- Monitor disk usage

## 🔧 Development

### Adding New Features

1. **New Pages**: Create template in `templates/`, add route in `routes/main.py`
2. **Database Changes**: Update models, create migration
3. **API Endpoints**: Add to `routes/api.py`
4. **Styling**: Update CSS files, maintain component structure

### Testing
```bash
# Run tests
pytest

# Test specific module
pytest tests/test_main.py

# Coverage report
pytest --cov=app
```

## 📝 License

[Your License Here]

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For issues with this website template:
- Create an issue on GitHub
- Contact: [your-email@example.com]

For the kubeopt tool itself:
- Visit the main documentation
- Docker Hub: `kubeopt/aks-optimizer`

---

**Note**: This is the marketing website for kubeopt. The actual cost optimization tool runs as a separate Docker container that customers deploy in their own environments.