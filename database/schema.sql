-- kubeopt Website Database Schema
-- SQLite compatible schema

-- Contact form submissions
CREATE TABLE IF NOT EXISTS contact (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL,
    company VARCHAR(100),
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'new',
    CONSTRAINT chk_status CHECK (status IN ('new', 'in_progress', 'resolved', 'closed'))
);

-- Page view analytics
CREATE TABLE IF NOT EXISTS page_view (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    page VARCHAR(100) NOT NULL,
    ip_address VARCHAR(45),
    user_agent VARCHAR(200),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    referrer VARCHAR(200),
    session_id VARCHAR(64)
);

-- Download tracking
CREATE TABLE IF NOT EXISTS download (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email VARCHAR(120) NOT NULL,
    version VARCHAR(20) DEFAULT 'latest',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent VARCHAR(200),
    download_type VARCHAR(50) DEFAULT 'docker',
    CONSTRAINT chk_download_type CHECK (download_type IN ('docker', 'helm', 'yaml', 'binary'))
);

-- Newsletter subscriptions
CREATE TABLE IF NOT EXISTS newsletter_subscription (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email VARCHAR(120) UNIQUE NOT NULL,
    subscribed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    unsubscribed_at DATETIME NULL,
    status VARCHAR(20) DEFAULT 'active',
    CONSTRAINT chk_newsletter_status CHECK (status IN ('active', 'unsubscribed', 'bounced'))
);

-- Event tracking for analytics
CREATE TABLE IF NOT EXISTS event (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type VARCHAR(50) NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    event_value VARCHAR(200),
    ip_address VARCHAR(45),
    user_agent VARCHAR(200),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    session_id VARCHAR(64),
    page_url VARCHAR(200)
);

-- User sessions (for basic analytics)
CREATE TABLE IF NOT EXISTS user_session (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id VARCHAR(64) UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent VARCHAR(200),
    first_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    page_views INTEGER DEFAULT 0,
    country VARCHAR(2),
    city VARCHAR(100)
);

-- Demo requests
CREATE TABLE IF NOT EXISTS demo_request (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL,
    company VARCHAR(100),
    phone VARCHAR(20),
    use_case TEXT,
    cluster_size VARCHAR(50),
    current_tools TEXT,
    preferred_time VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    CONSTRAINT chk_demo_status CHECK (status IN ('pending', 'scheduled', 'completed', 'cancelled'))
);

-- Feature requests and feedback
CREATE TABLE IF NOT EXISTS feedback (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    email VARCHAR(120),
    priority VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(20) DEFAULT 'open',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_feedback_type CHECK (type IN ('bug', 'feature', 'improvement', 'question')),
    CONSTRAINT chk_feedback_priority CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    CONSTRAINT chk_feedback_status CHECK (status IN ('open', 'in_progress', 'resolved', 'closed'))
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_contact_created_at ON contact(created_at);
CREATE INDEX IF NOT EXISTS idx_contact_status ON contact(status);

CREATE INDEX IF NOT EXISTS idx_page_view_timestamp ON page_view(timestamp);
CREATE INDEX IF NOT EXISTS idx_page_view_page ON page_view(page);

CREATE INDEX IF NOT EXISTS idx_download_timestamp ON download(timestamp);
CREATE INDEX IF NOT EXISTS idx_download_email ON download(email);

CREATE INDEX IF NOT EXISTS idx_event_timestamp ON event(timestamp);
CREATE INDEX IF NOT EXISTS idx_event_type ON event(event_type);

CREATE INDEX IF NOT EXISTS idx_session_last_seen ON user_session(last_seen);
CREATE INDEX IF NOT EXISTS idx_session_id ON user_session(session_id);

CREATE INDEX IF NOT EXISTS idx_demo_created_at ON demo_request(created_at);
CREATE INDEX IF NOT EXISTS idx_demo_status ON demo_request(status);

CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON feedback(created_at);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback(status);

-- Insert some initial data for development
INSERT OR IGNORE INTO contact (name, email, company, message, status) VALUES 
('John Doe', 'john@example.com', 'Example Corp', 'Interested in enterprise pricing', 'new'),
('Jane Smith', 'jane@tech.co', 'Tech Startup', 'Need help with integration', 'in_progress');

INSERT OR IGNORE INTO download (email, version, download_type) VALUES 
('dev@example.com', 'latest', 'docker'),
('admin@company.com', 'v1.0.0', 'helm');

INSERT OR IGNORE INTO newsletter_subscription (email, status) VALUES 
('newsletter@example.com', 'active'),
('updates@company.com', 'active');

-- Views for common queries
CREATE VIEW IF NOT EXISTS monthly_stats AS
SELECT 
    strftime('%Y-%m', created_at) as month,
    COUNT(*) as total_contacts,
    COUNT(CASE WHEN status = 'new' THEN 1 END) as new_contacts,
    COUNT(CASE WHEN status = 'resolved' THEN 1 END) as resolved_contacts
FROM contact 
GROUP BY strftime('%Y-%m', created_at)
ORDER BY month DESC;

CREATE VIEW IF NOT EXISTS daily_downloads AS
SELECT 
    DATE(timestamp) as date,
    COUNT(*) as total_downloads,
    COUNT(DISTINCT email) as unique_users
FROM download 
GROUP BY DATE(timestamp)
ORDER BY date DESC;

CREATE VIEW IF NOT EXISTS popular_pages AS
SELECT 
    page,
    COUNT(*) as views,
    COUNT(DISTINCT ip_address) as unique_visitors
FROM page_view 
GROUP BY page 
ORDER BY views DESC;

-- Triggers for automatic timestamp updates
CREATE TRIGGER IF NOT EXISTS update_feedback_timestamp 
    AFTER UPDATE ON feedback
    BEGIN
        UPDATE feedback SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;