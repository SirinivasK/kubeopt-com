// Main JavaScript for kubeopt Website
document.addEventListener('DOMContentLoaded', function() {
    // Initialize all components
    initializeNavigation();
    initializeScrollEffects();
    initializeAnimations();
    initializeForms();
    initializeCharts();
    initializeAnalytics();
});

// Navigation functionality
function initializeNavigation() {
    const mobileMenuToggle = document.getElementById('mobileMenuToggle');
    const mobileMenu = document.getElementById('mobileMenu');
    const header = document.querySelector('.header');
    
    // Mobile menu toggle
    if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener('click', function() {
            mobileMenu.classList.toggle('active');
            this.classList.toggle('active');
        });
    }
    
    // Close mobile menu when clicking on links
    const mobileNavLinks = document.querySelectorAll('.mobile-nav-link');
    mobileNavLinks.forEach(link => {
        link.addEventListener('click', function() {
            mobileMenu.classList.remove('active');
            mobileMenuToggle.classList.remove('active');
        });
    });
    
    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Header scroll effect
    window.addEventListener('scroll', function() {
        if (window.scrollY > 100) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    });
}

// Scroll effects and animations
function initializeScrollEffects() {
    // Intersection Observer for fade-in animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in-up');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);
    
    // Observe elements with animation classes
    document.querySelectorAll('.animate-on-scroll').forEach(el => {
        observer.observe(el);
    });
    
    // Parallax effect for hero section
    const heroSection = document.querySelector('.hero');
    if (heroSection) {
        window.addEventListener('scroll', function() {
            const scrolled = window.pageYOffset;
            const rate = scrolled * -0.5;
            heroSection.style.transform = `translateY(${rate}px)`;
        });
    }
}

// Animation utilities
function initializeAnimations() {
    // Counter animation for statistics
    function animateCounter(element, target, duration = 2000) {
        let start = 0;
        const increment = target / (duration / 16);
        
        function updateCounter() {
            start += increment;
            if (start < target) {
                element.textContent = Math.floor(start);
                requestAnimationFrame(updateCounter);
            } else {
                element.textContent = target;
            }
        }
        
        updateCounter();
    }
    
    // Animate counters when they come into view
    const counters = document.querySelectorAll('.counter');
    const counterObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const target = parseInt(entry.target.dataset.target);
                animateCounter(entry.target, target);
                counterObserver.unobserve(entry.target);
            }
        });
    });
    
    counters.forEach(counter => {
        counterObserver.observe(counter);
    });
    
    // Typing animation for code blocks
    function typeWriter(element, text, speed = 50) {
        let i = 0;
        element.innerHTML = '';
        
        function type() {
            if (i < text.length) {
                element.innerHTML += text.charAt(i);
                i++;
                setTimeout(type, speed);
            }
        }
        
        type();
    }
    
    // Initialize typing animation for demo code
    const codeElement = document.querySelector('.demo-code');
    if (codeElement) {
        const codeText = codeElement.textContent;
        const codeObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    typeWriter(entry.target, codeText, 30);
                    codeObserver.unobserve(entry.target);
                }
            });
        });
        codeObserver.observe(codeElement);
    }
}

// Form handling
function initializeForms() {
    // Contact form submission
    const contactForm = document.getElementById('contactForm');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const submitButton = this.querySelector('button[type="submit"]');
            const originalText = submitButton.textContent;
            
            // Show loading state
            submitButton.textContent = 'Sending...';
            submitButton.disabled = true;
            
            fetch('/contact', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showFlashMessage('Thank you! We\'ll get back to you soon.', 'success');
                    contactForm.reset();
                } else {
                    showFlashMessage('Sorry, there was an error. Please try again.', 'error');
                }
            })
            .catch(error => {
                showFlashMessage('Sorry, there was an error. Please try again.', 'error');
            })
            .finally(() => {
                submitButton.textContent = originalText;
                submitButton.disabled = false;
            });
        });
    }
    
    // Newsletter subscription
    const newsletterForm = document.getElementById('newsletterForm');
    if (newsletterForm) {
        newsletterForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const email = this.querySelector('input[type="email"]').value;
            
            fetch('/api/newsletter', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email: email })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showFlashMessage('Successfully subscribed to our newsletter!', 'success');
                    this.reset();
                } else {
                    showFlashMessage('Sorry, there was an error. Please try again.', 'error');
                }
            });
        });
    }
    
    // Download form
    const downloadForm = document.getElementById('downloadForm');
    if (downloadForm) {
        downloadForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const email = this.querySelector('input[type="email"]').value;
            
            fetch('/api/download', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email: email })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showDownloadInstructions(data.download_url, data.instructions);
                } else {
                    showFlashMessage('Sorry, there was an error. Please try again.', 'error');
                }
            });
        });
    }
}

// Chart initialization
function initializeCharts() {
    // Load Chart.js if not already loaded
    if (typeof Chart === 'undefined') {
        const script = document.createElement('script');
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js';
        script.onload = function() {
            loadChartData();
        };
        document.head.appendChild(script);
    } else {
        loadChartData();
    }
}

function loadChartData() {
    fetch('/api/demo-data')
        .then(response => response.json())
        .then(data => {
            createCharts(data);
        })
        .catch(error => {
            console.log('Charts will use static data');
            createChartsWithStaticData();
        });
}

function createCharts(data) {
    // Cost Trends Chart
    const costCtx = document.getElementById('costTrendsChart');
    if (costCtx) {
        new Chart(costCtx, {
            type: 'line',
            data: {
                labels: data.cost_trends.labels,
                datasets: [{
                    label: 'Current Cost',
                    data: data.cost_trends.current,
                    borderColor: '#f56565',
                    backgroundColor: 'rgba(245, 101, 101, 0.1)',
                    tension: 0.4,
                    fill: true
                }, {
                    label: 'Optimized Cost',
                    data: data.cost_trends.optimized,
                    borderColor: '#4299e1',
                    backgroundColor: 'rgba(66, 153, 225, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#cbd5e0'
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            color: '#a0aec0',
                            callback: function(value) {
                                return '$' + (value/1000).toFixed(0) + 'k';
                            }
                        },
                        grid: {
                            color: 'rgba(160, 174, 192, 0.2)'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#a0aec0'
                        },
                        grid: {
                            color: 'rgba(160, 174, 192, 0.2)'
                        }
                    }
                }
            }
        });
    }
    
    // Resource Utilization Chart
    const utilizationCtx = document.getElementById('utilizationChart');
    if (utilizationCtx) {
        new Chart(utilizationCtx, {
            type: 'bar',
            data: {
                labels: data.utilization.labels,
                datasets: [{
                    label: 'Current Usage',
                    data: data.utilization.current,
                    backgroundColor: '#f56565',
                    borderRadius: 5
                }, {
                    label: 'Optimized Usage',
                    data: data.utilization.optimized,
                    backgroundColor: '#4299e1',
                    borderRadius: 5
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#cbd5e0'
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100,
                        ticks: {
                            color: '#a0aec0',
                            callback: function(value) {
                                return value + '%';
                            }
                        },
                        grid: {
                            color: 'rgba(160, 174, 192, 0.2)'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#a0aec0'
                        },
                        grid: {
                            color: 'rgba(160, 174, 192, 0.2)'
                        }
                    }
                }
            }
        });
    }
    
    // Additional charts...
    createEfficiencyChart(data.efficiency);
    createSavingsChart(data.savings);
}

function createChartsWithStaticData() {
    // Static demo data for when API is not available
    const staticData = {
        cost_trends: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            current: [12000, 14000, 13500, 15000, 16000, 14500],
            optimized: [8000, 9500, 9000, 10500, 11000, 9800]
        },
        utilization: {
            labels: ['CPU', 'Memory', 'Storage', 'Network'],
            current: [85, 78, 92, 65],
            optimized: [72, 68, 80, 58]
        },
        efficiency: {
            labels: ['Optimized', 'Over-provisioned', 'Under-provisioned'],
            data: [65, 25, 10]
        },
        savings: {
            labels: ['Compute', 'Storage', 'Network', 'Other'],
            data: [3500, 1200, 800, 400]
        }
    };
    
    createCharts(staticData);
}

function createEfficiencyChart(data) {
    const efficiencyCtx = document.getElementById('efficiencyChart');
    if (efficiencyCtx) {
        new Chart(efficiencyCtx, {
            type: 'doughnut',
            data: {
                labels: data.labels,
                datasets: [{
                    data: data.data,
                    backgroundColor: ['#48bb78', '#f56565', '#ed8936'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                cutout: '70%',
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#cbd5e0'
                        }
                    }
                }
            }
        });
    }
}

function createSavingsChart(data) {
    const savingsCtx = document.getElementById('savingsChart');
    if (savingsCtx) {
        new Chart(savingsCtx, {
            type: 'bar',
            data: {
                labels: data.labels,
                datasets: [{
                    label: 'Monthly Savings',
                    data: data.data,
                    backgroundColor: ['#4299e1', '#3182ce', '#63b3ed', '#90cdf4'],
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            color: '#a0aec0',
                            callback: function(value) {
                                return '$' + value.toLocaleString();
                            }
                        },
                        grid: {
                            color: 'rgba(160, 174, 192, 0.2)'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#a0aec0'
                        },
                        grid: {
                            color: 'rgba(160, 174, 192, 0.2)'
                        }
                    }
                }
            }
        });
    }
}

// Analytics tracking
function initializeAnalytics() {
    // Track page views
    trackPageView();
    
    // Track button clicks
    document.querySelectorAll('[data-track]').forEach(element => {
        element.addEventListener('click', function() {
            const action = this.dataset.track;
            trackEvent('click', action);
        });
    });
    
    // Track form submissions
    document.querySelectorAll('form').forEach(form => {
        form.addEventListener('submit', function() {
            const formName = this.id || 'unknown';
            trackEvent('form_submit', formName);
        });
    });
}

function trackPageView() {
    const page = window.location.pathname;
    // Send to your analytics endpoint
    fetch('/api/analytics/pageview', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ page: page })
    }).catch(() => {}); // Fail silently
}

function trackEvent(action, label) {
    // Send to your analytics endpoint
    fetch('/api/analytics/event', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ action: action, label: label })
    }).catch(() => {}); // Fail silently
}

// Utility functions
function showFlashMessage(message, type = 'info') {
    const flashContainer = document.querySelector('.flash-messages') || createFlashContainer();
    
    const flashElement = document.createElement('div');
    flashElement.className = `flash-message flash-${type}`;
    flashElement.innerHTML = `
        <span class="flash-text">${message}</span>
        <button class="flash-close" onclick="this.parentElement.remove()">×</button>
    `;
    
    flashContainer.appendChild(flashElement);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (flashElement.parentNode) {
            flashElement.remove();
        }
    }, 5000);
}

function createFlashContainer() {
    const container = document.createElement('div');
    container.className = 'flash-messages';
    document.body.appendChild(container);
    return container;
}

function showDownloadInstructions(downloadUrl, instructions) {
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-content">
            <div class="modal-header">
                <h3>Download kubeopt</h3>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                <p>Run this command to get started:</p>
                <div class="code-block">
                    <code>${downloadUrl}</code>
                </div>
                <p>${instructions}</p>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
    
    // Close modal functionality
    modal.querySelector('.modal-close').addEventListener('click', () => {
        modal.remove();
    });
    
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.remove();
        }
    });
}

// Clipboard functionality
function copyToClipboard(text) {
    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(() => {
            showFlashMessage('Copied to clipboard!', 'success');
        });
    } else {
        // Fallback for older browsers
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        showFlashMessage('Copied to clipboard!', 'success');
    }
}

// Add copy buttons to code blocks that don't already have them
document.querySelectorAll('.code-block').forEach(block => {
    // Skip if block already has a copy button
    if (block.querySelector('.copy-button, .copy-btn')) {
        return;
    }
    
    const copyButton = document.createElement('button');
    copyButton.className = 'copy-button';
    copyButton.innerHTML = '📋 Copy';
    copyButton.onclick = function() {
        // Use the button's textContent fallback approach
        const text = block.textContent.trim();
        if (navigator.clipboard) {
            navigator.clipboard.writeText(text).then(() => {
                const originalText = this.textContent;
                this.textContent = 'Copied!';
                this.classList.add('copied');
                setTimeout(() => {
                    this.textContent = originalText;
                    this.classList.remove('copied');
                }, 2000);
            }).catch(() => {
                fallbackCopyDirect(text, this);
            });
        } else {
            fallbackCopyDirect(text, this);
        }
    };
    
    block.style.position = 'relative';
    block.appendChild(copyButton);
});

// Direct fallback copy function for auto-generated buttons
function fallbackCopyDirect(text, button) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
    
    const originalText = button.textContent;
    button.textContent = 'Copied!';
    button.classList.add('copied');
    setTimeout(() => {
        button.textContent = originalText;
        button.classList.remove('copied');
    }, 2000);
}

// Tab functionality for docs section
function initializeDocsTabs() {
    const tabs = document.querySelectorAll('.tab');
    const contents = document.querySelectorAll('.command-content');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', function() {
            const targetTab = this.dataset.tab;
            
            // Remove active class from all tabs and contents
            tabs.forEach(t => t.classList.remove('active'));
            contents.forEach(c => c.classList.remove('active'));
            
            // Add active class to clicked tab and corresponding content
            this.classList.add('active');
            document.querySelector(`[data-content="${targetTab}"]`).classList.add('active');
        });
    });
}

// Initialize docs tabs when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeDocsTabs();
});

// Add active navigation highlighting based on scroll position
function updateActiveNavigation() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-link');
    
    let current = '';
    
    sections.forEach(section => {
        const sectionTop = section.offsetTop - 100;
        const sectionHeight = section.offsetHeight;
        
        if (window.scrollY >= sectionTop && window.scrollY < sectionTop + sectionHeight) {
            current = section.id;
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${current}`) {
            link.classList.add('active');
        }
    });
}

// Update navigation on scroll
window.addEventListener('scroll', updateActiveNavigation);

// Enhanced copy functionality for code snippets
function copyToClipboard(button) {
    if (!button) {
        console.error('copyToClipboard: button parameter is undefined');
        return;
    }
    
    const codeElement = button.previousElementSibling || 
                       (button.parentElement ? button.parentElement.querySelector('code') : null);
    
    if (!codeElement) {
        console.error('copyToClipboard: could not find code element');
        return;
    }
    
    const text = codeElement.textContent.trim();
    
    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(() => {
            const originalText = button.textContent;
            button.textContent = 'Copied!';
            button.classList.add('copied');
            setTimeout(() => {
                button.textContent = originalText;
                button.classList.remove('copied');
            }, 2000);
        }).catch(() => {
            // Fallback if clipboard API fails
            fallbackCopy(text, button);
        });
    } else {
        fallbackCopy(text, button);
    }
}

function fallbackCopy(text, button) {
    if (!button) {
        console.error('fallbackCopy: button parameter is undefined');
        return;
    }
    
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
    
    const originalText = button.textContent;
    button.textContent = 'Copied!';
    button.classList.add('copied');
    setTimeout(() => {
        button.textContent = originalText;
        button.classList.remove('copied');
    }, 2000);
}

// Export functions for use in templates
window.kubeopt = {
    showFlashMessage,
    copyToClipboard,
    trackEvent
};