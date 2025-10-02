# kubeopt.com Website

A professional marketing and information website for the kubeopt AKS cost optimization tool. This Flask-based website showcases your containerized ML-driven Kubernetes optimizer.

## 🌐 **Live Website**
**URL**: [https://kubeopt.com](https://kubeopt.com)  
**Status**: ✅ **LIVE & DEPLOYED**  
**Infrastructure**: Azure Kubernetes Service (AKS)  
**External IP**: `172.199.86.63`

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

## 🚀 Production Deployment (Azure Kubernetes Service)

### **Current Production Setup**
The website is deployed on Azure Kubernetes Service (AKS) with the following architecture:

```
GoDaddy DNS (kubeopt.com) → Azure Load Balancer (172.199.86.63) → NGINX Ingress → AKS Cluster → kubeopt-website Pod
```

### **Infrastructure Components**
- **AKS Cluster**: `aks-kubeopt-com-prod` in West Europe
- **Container Registry**: `acrkubeoptioprod.azurecr.io`
- **Image**: `acrkubeoptioprod.azurecr.io/kubeopt-com:amd64`
- **Ingress Controller**: NGINX with Let's Encrypt SSL
- **External IP**: `172.199.86.63`

### **Deployment Architecture**
```yaml
# Production deployment includes:
- Namespace: kubeopt-com
- Deployment: kubeopt-website (1 replica, autoscaling enabled)
- Service: kubeopt-website (ClusterIP)
- Ingress: kubeopt-website-ingress (HTTPS with SSL)
- Secrets: kubeopt-secrets (Flask secret key)
- SSL: Let's Encrypt certificates (auto-renewal)
```

### **DNS Configuration**
```
# GoDaddy DNS Records
Type: A
Name: @ (kubeopt.com)
Value: 172.199.86.63

Type: A  
Name: www
Value: 172.199.86.63
```

### **Build & Deploy Process**

#### 1. Build Docker Image for AMD64
```bash
# Build for correct architecture (AKS requires AMD64)
docker buildx build --platform linux/amd64 -t kubeopt-website:amd64 .

# Tag for Azure Container Registry
docker tag kubeopt-website:amd64 acrkubeoptioprod.azurecr.io/kubeopt-com:amd64
```

#### 2. Push to Azure Container Registry
```bash
# Login to ACR
az acr login --name acrkubeoptioprod

# Push image
docker push acrkubeoptioprod.azurecr.io/kubeopt-com:amd64
```

#### 3. Deploy to AKS
```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/storage.yaml  
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

# Verify deployment
kubectl get pods -n kubeopt-com
kubectl get ingress -n kubeopt-com
```

#### 4. NGINX Ingress Controller Setup
```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Verify external IP assignment
kubectl get svc -n ingress-nginx
```

### **SSL Certificate Management**
- **Provider**: Let's Encrypt (via cert-manager)
- **Auto-renewal**: Enabled
- **Challenge**: HTTP-01
- **Certificates**: kubeopt.com, www.kubeopt.com

### **Monitoring & Health Checks**
```bash
# Check deployment status
kubectl get deployment kubeopt-website -n kubeopt-com

# View pod logs
kubectl logs -f deployment/kubeopt-website -n kubeopt-com

# Health check endpoint
curl https://kubeopt.com/health

# Test website
curl -I https://kubeopt.com
```

### **Deployment Fixes Applied**
See [docs/DEPLOYMENT-FIXES.md](docs/DEPLOYMENT-FIXES.md) for detailed documentation of issues resolved:
1. **Image Architecture**: Fixed ARM64 → AMD64 compatibility
2. **Container Registry**: Set up proper ACR integration  
3. **Kubernetes Secrets**: Created required `kubeopt-secrets`
4. **File Permissions**: Resolved volume mount permissions
5. **Ingress Controller**: Installed and configured NGINX ingress

### **Alternative Deployment Options**

#### Traditional Hosting (VPS/Dedicated)
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

#### Docker Production (Non-Kubernetes)
```bash
# Build and deploy
docker build -t kubeopt-website .
docker run -d --name kubeopt-web -p 80:5000 kubeopt-website
```

#### Cloud Platforms
- **Heroku**: Include `Procfile` with `web: gunicorn app.main:app`
- **Railway**: Direct deploy from GitHub
- **DigitalOcean App Platform**: Use `app.yaml` config
- **AWS ECS**: Use provided Dockerfile

## 📈 Monitoring & Maintenance

### Production Health Monitoring
```bash
# Application health check
curl https://kubeopt.com/health

# Kubernetes pod status
kubectl get pods -n kubeopt-com

# Ingress status
kubectl get ingress -n kubeopt-com

# SSL certificate status
kubectl get certificates -n kubeopt-com
```

### Database Maintenance (Production)
```bash
# Access database via pod
kubectl exec -it deployment/kubeopt-website -n kubeopt-com -- sqlite3 /app/database/kubeopt.db

# Backup database from running pod
kubectl cp kubeopt-com/$(kubectl get pod -n kubeopt-com -l app=kubeopt-website -o jsonpath='{.items[0].metadata.name}'):/app/database/kubeopt.db ./backup-$(date +%Y%m%d).db

# Clean old analytics data (optional)
kubectl exec -it deployment/kubeopt-website -n kubeopt-com -- sqlite3 /app/database/kubeopt.db "DELETE FROM page_view WHERE timestamp < date('now', '-90 days');"
```

### Log Management
```bash
# View application logs
kubectl logs -f deployment/kubeopt-website -n kubeopt-com

# View ingress controller logs
kubectl logs -f deployment/ingress-nginx-controller -n ingress-nginx

# View past 1 hour of logs
kubectl logs --since=1h deployment/kubeopt-website -n kubeopt-com
```

### Performance Monitoring
```bash
# Pod resource usage
kubectl top pods -n kubeopt-com

# Node resource usage  
kubectl top nodes

# HPA status
kubectl get hpa -n kubeopt-com
```

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

## 🎯 **Next Steps for DNS Setup**

To complete the website deployment to your domain:

### **1. Update GoDaddy DNS Records**
Login to your [GoDaddy DNS Management](https://dcc.godaddy.com/manage/dns) and add/update:

```
Type: A
Name: @ (kubeopt.com)  
Value: 172.199.86.63
TTL: 1 Hour

Type: A
Name: www
Value: 172.199.86.63  
TTL: 1 Hour
```

### **2. Wait for DNS Propagation**
- **Time**: 5-30 minutes typically
- **Check**: Use `nslookup kubeopt.com` to verify DNS resolution
- **Test**: Visit `https://kubeopt.com` once DNS propagates

### **3. SSL Certificate Auto-Generation**
Once DNS points to the correct IP:
- Let's Encrypt will automatically issue SSL certificates
- The site will be accessible via HTTPS
- HTTP traffic will redirect to HTTPS automatically

### **4. Verify Deployment**
```bash
# Check certificate status
kubectl get certificates -n kubeopt-com

# Test website accessibility  
curl -I https://kubeopt.com

# Monitor certificate issuance
kubectl describe certificate kubeopt-com-tls -n kubeopt-com
```

---

## 📊 **Current Deployment Status**

✅ **AKS Cluster**: Running  
✅ **Application**: Deployed and healthy  
✅ **Ingress Controller**: Configured with external IP  
✅ **SSL Setup**: Let's Encrypt configured  
✅ **Domain**: Ready for DNS configuration  
🔄 **DNS**: Needs GoDaddy update to `172.199.86.63`  

**Website**: Fully functional and ready for public access once DNS is updated!

---

**Note**: This is the marketing website for kubeopt. The actual cost optimization tool runs as a separate Docker container that customers deploy in their own environments.