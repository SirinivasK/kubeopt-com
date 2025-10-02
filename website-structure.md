# kubeopt.com Website - Project Structure

```
kubeopt-website/
├── README.md
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .gitignore
│
├── app/
│   ├── __init__.py
│   ├── main.py              # Flask application entry point
│   ├── config.py            # Configuration settings
│   ├── models/
│   │   ├── __init__.py
│   │   ├── database.py      # SQLite database setup
│   │   ├── contact.py       # Contact form model
│   │   └── analytics.py     # Basic analytics model
│   │
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── main.py          # Main website routes
│   │   ├── api.py           # API endpoints
│   │   └── admin.py         # Admin panel routes
│   │
│   ├── static/
│   │   ├── css/
│   │   │   ├── main.css     # Main stylesheet
│   │   │   ├── components.css
│   │   │   └── responsive.css
│   │   │
│   │   ├── js/
│   │   │   ├── main.js      # Main JavaScript
│   │   │   ├── charts.js    # Chart configurations
│   │   │   ├── animations.js
│   │   │   └── contact.js   # Contact form handling
│   │   │
│   │   ├── images/
│   │   │   ├── logo.png
│   │   │   ├── dashboard-preview.png
│   │   │   └── icons/
│   │   │
│   │   └── libs/
│   │       ├── chart.js
│   │       └── aos.css      # Animation library
│   │
│   ├── templates/
│   │   ├── base.html        # Base template
│   │   ├── index.html       # Homepage
│   │   ├── features.html    # Features page
│   │   ├── pricing.html     # Pricing page
│   │   ├── docs.html        # Documentation
│   │   ├── contact.html     # Contact page
│   │   └── admin/
│   │       ├── dashboard.html
│   │       └── contacts.html
│   │
│   └── utils/
│       ├── __init__.py
│       ├── email.py         # Email utilities
│       └── helpers.py       # Helper functions
│
├── database/
│   ├── init.sql            # Database initialization
│   ├── schema.sql          # Database schema
│   └── kubeopt.db        # SQLite database file (auto-generated)
│
├── scripts/
│   ├── setup.sh           # Setup script
│   ├── deploy.sh          # Deployment script
│   └── backup.sh          # Database backup
│
├── tests/
│   ├── __init__.py
│   ├── test_main.py
│   └── test_api.py
│
└── docs/
    ├── API.md
    ├── DEPLOYMENT.md
    └── DEVELOPMENT.md
```

## Key Components

### 1. **Python Backend (Flask)**
- Simple, lightweight web framework
- SQLite for contact forms and basic analytics
- API endpoints for dynamic content
- Admin panel for managing inquiries

### 2. **Frontend Structure**
- **CSS**: Modular stylesheets for maintainability
- **JavaScript**: Interactive elements, charts, animations
- **Templates**: Jinja2 templates for dynamic content

### 3. **Database (SQLite)**
- Contact form submissions
- Newsletter signups
- Basic page analytics
- Download tracking

### 4. **Container Ready**
- Dockerfile for easy deployment
- docker-compose for development
- Environment configuration

### 5. **Features**
- ✅ Responsive design (mobile-first)
- ✅ Interactive dashboard previews
- ✅ Contact form with email notifications
- ✅ Basic analytics tracking
- ✅ Admin panel for content management
- ✅ API endpoints for future integrations
- ✅ SEO optimized

This structure separates concerns properly while keeping the project simple and maintainable. Perfect for a marketing website that showcases your containerized tool!