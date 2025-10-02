// Advanced Chart Configurations - kubeopt Green/White Theme
// Modern, sleek charts that match the aks-cost-optimizer tool

// Chart.js Default Configuration
Chart.defaults.font.family = "'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
Chart.defaults.font.size = 12;
Chart.defaults.color = '#374151';

// Color Palette - Matching the green theme
const chartColors = {
    primary: '#22c55e',
    primaryLight: '#4ade80',
    primaryDark: '#16a34a',
    secondary: '#3b82f6',
    secondaryLight: '#60a5fa',
    accent: '#f59e0b',
    success: '#10b981',
    warning: '#f59e0b',
    error: '#ef4444',
    gray: '#6b7280',
    white: '#ffffff',
    background: '#f8fffe',
    
    // Gradient colors
    gradients: {
        green: ['#22c55e', '#16a34a'],
        blue: ['#3b82f6', '#2563eb'],
        mixed: ['#22c55e', '#3b82f6', '#f59e0b'],
        cost: ['#ef4444', '#f59e0b', '#22c55e'],
        performance: ['#22c55e', '#4ade80', '#86efac']
    }
};

// Create gradient function
function createGradient(ctx, colors, direction = 'vertical') {
    const gradient = direction === 'vertical' 
        ? ctx.createLinearGradient(0, 0, 0, 400)
        : ctx.createLinearGradient(0, 0, 400, 0);
    
    colors.forEach((color, index) => {
        gradient.addColorStop(index / (colors.length - 1), color);
    });
    
    return gradient;
}

// Initialize all charts when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeCostTrendsChart();
    initializeNodeUtilizationChart();
    initializeCostDistributionChart();
    initializeSavingsBreakdownChart();
    animateCounters();
    initializeScrollAnimations();
});

// Cost Trends Chart - Line Chart with Gradient
function initializeCostTrendsChart() {
    const ctx = document.getElementById('costTrendsChart');
    if (!ctx) return;
    
    const chartCtx = ctx.getContext('2d');
    
    new Chart(chartCtx, {
        type: 'line',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            datasets: [{
                label: 'Current Cost',
                data: [12500, 13200, 12800, 14100, 13800, 8420],
                borderColor: chartColors.error,
                backgroundColor: function(context) {
                    const chart = context.chart;
                    const {ctx, chartArea} = chart;
                    if (!chartArea) return null;
                    
                    const gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom);
                    gradient.addColorStop(0, 'rgba(239, 68, 68, 0.3)');
                    gradient.addColorStop(1, 'rgba(239, 68, 68, 0.05)');
                    return gradient;
                },
                borderWidth: 3,
                fill: true,
                tension: 0.4,
                pointBackgroundColor: chartColors.error,
                pointBorderColor: chartColors.white,
                pointBorderWidth: 3,
                pointRadius: 6,
                pointHoverRadius: 8,
                pointHoverBackgroundColor: chartColors.error,
                pointHoverBorderColor: chartColors.white,
                pointHoverBorderWidth: 3
            }, {
                label: 'Optimized Cost',
                data: [8200, 8400, 8100, 8800, 8600, 5240],
                borderColor: chartColors.primary,
                backgroundColor: function(context) {
                    const chart = context.chart;
                    const {ctx, chartArea} = chart;
                    if (!chartArea) return null;
                    
                    const gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom);
                    gradient.addColorStop(0, 'rgba(34, 197, 94, 0.3)');
                    gradient.addColorStop(1, 'rgba(34, 197, 94, 0.05)');
                    return gradient;
                },
                borderWidth: 3,
                fill: true,
                tension: 0.4,
                pointBackgroundColor: chartColors.primary,
                pointBorderColor: chartColors.white,
                pointBorderWidth: 3,
                pointRadius: 6,
                pointHoverRadius: 8,
                pointHoverBackgroundColor: chartColors.primary,
                pointHoverBorderColor: chartColors.white,
                pointHoverBorderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            aspectRatio: 1.5,
            interaction: {
                intersect: false,
                mode: 'index'
            },
            plugins: {
                legend: {
                    position: 'top',
                    align: 'end',
                    labels: {
                        usePointStyle: true,
                        pointStyle: 'circle',
                        padding: 20,
                        font: {
                            weight: '600'
                        }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(255, 255, 255, 0.95)',
                    titleColor: '#111827',
                    bodyColor: '#374151',
                    borderColor: '#22c55e',
                    borderWidth: 2,
                    cornerRadius: 12,
                    displayColors: true,
                    callbacks: {
                        label: function(context) {
                            return context.dataset.label + ': $' + context.parsed.y.toLocaleString();
                        }
                    }
                }
            },
            scales: {
                x: {
                    grid: {
                        display: false
                    },
                    border: {
                        display: false
                    },
                    ticks: {
                        font: {
                            weight: '500'
                        }
                    }
                },
                y: {
                    grid: {
                        color: '#f0fdf4',
                        drawBorder: false
                    },
                    border: {
                        display: false
                    },
                    ticks: {
                        callback: function(value) {
                            return '$' + (value / 1000) + 'K';
                        },
                        font: {
                            weight: '500'
                        }
                    }
                }
            },
            animation: {
                duration: 2000,
                easing: 'easeInOutCubic'
            }
        }
    });
}

// Node Resource Utilization Chart - Bar Chart
function initializeNodeUtilizationChart() {
    const ctx = document.getElementById('nodeUtilizationChart');
    if (!ctx) return;
    
    const chartCtx = ctx.getContext('2d');
    
    // Node data from your screenshots
    const nodeLabels = [
        'aks-agentpool-566764...', 'aks-agentpool-566764...', 'aks-agentpool-566764...',
        'aks-agentpool-566764...', 'aks-agentpool-566764...', 'aks-agentpool-566764...',
        'aks-agentpool-566764...', 'aks-agentpool-566764...', 'aks-agentpool-566764...'
    ];
    
    new Chart(chartCtx, {
        type: 'bar',
        data: {
            labels: nodeLabels,
            datasets: [{
                label: 'CPU Actual %',
                data: [45, 52, 38, 61, 33, 47, 55, 42, 39],
                backgroundColor: chartColors.error,
                borderRadius: 4,
                borderSkipped: false,
            }, {
                label: 'CPU Request %',
                data: [35, 42, 28, 51, 23, 37, 45, 32, 29],
                backgroundColor: chartColors.warning,
                borderRadius: 4,
                borderSkipped: false,
            }, {
                label: 'Memory Actual %',
                data: [65, 72, 58, 81, 53, 67, 75, 62, 59],
                backgroundColor: chartColors.primary,
                borderRadius: 4,
                borderSkipped: false,
            }, {
                label: 'Memory Request %',
                data: [55, 62, 48, 71, 43, 57, 65, 52, 49],
                backgroundColor: chartColors.secondary,
                borderRadius: 4,
                borderSkipped: false,
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            aspectRatio: 1.5,
            plugins: {
                legend: {
                    position: 'top',
                    align: 'end',
                    labels: {
                        usePointStyle: true,
                        pointStyle: 'rect',
                        padding: 15,
                        font: {
                            weight: '600',
                            size: 11
                        }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(255, 255, 255, 0.95)',
                    titleColor: '#111827',
                    bodyColor: '#374151',
                    borderColor: '#22c55e',
                    borderWidth: 2,
                    cornerRadius: 12,
                    callbacks: {
                        label: function(context) {
                            return context.dataset.label + ': ' + context.parsed.y + '%';
                        }
                    }
                }
            },
            scales: {
                x: {
                    grid: {
                        display: false
                    },
                    border: {
                        display: false
                    },
                    ticks: {
                        font: {
                            size: 10
                        },
                        maxRotation: 45
                    }
                },
                y: {
                    grid: {
                        color: '#f0fdf4',
                        drawBorder: false
                    },
                    border: {
                        display: false
                    },
                    ticks: {
                        callback: function(value) {
                            return value + '%';
                        },
                        font: {
                            weight: '500'
                        }
                    },
                    max: 100
                }
            },
            animation: {
                duration: 2000,
                easing: 'easeInOutCubic'
            }
        }
    });
}

// Cost Distribution Chart - Doughnut Chart
function initializeCostDistributionChart() {
    const ctx = document.getElementById('costDistributionChart');
    if (!ctx) return;
    
    const chartCtx = ctx.getContext('2d');
    
    new Chart(chartCtx, {
        type: 'doughnut',
        data: {
            labels: ['Node Pools', 'Storage', 'Networking', 'Control Plane', 'Container Registry', 'Other'],
            datasets: [{
                data: [1180167, 548864, 532390, 438122, 87339, 115554],
                backgroundColor: [
                    '#3b82f6', // Blue for Node Pools (largest)
                    '#f59e0b', // Orange for Storage  
                    '#10b981', // Green for Networking
                    '#8b5cf6', // Purple for Control Plane
                    '#ef4444', // Red for Container Registry
                    '#6b7280'  // Gray for Other
                ],
                borderColor: chartColors.white,
                borderWidth: 3,
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            aspectRatio: 1.5,
            cutout: '60%',
            plugins: {
                legend: {
                    position: 'right',
                    labels: {
                        usePointStyle: true,
                        pointStyle: 'circle',
                        padding: 15,
                        font: {
                            weight: '600',
                            size: 11
                        },
                        generateLabels: function(chart) {
                            const data = chart.data;
                            if (data.labels.length && data.datasets.length) {
                                return data.labels.map((label, i) => {
                                    const value = data.datasets[0].data[i];
                                    const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                                    const percentage = ((value / total) * 100).toFixed(1);
                                    return {
                                        text: `${label}: $${(value/1000).toFixed(0)}K (${percentage}%)`,
                                        fillStyle: data.datasets[0].backgroundColor[i],
                                        hidden: false,
                                        index: i
                                    };
                                });
                            }
                            return [];
                        }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(255, 255, 255, 0.95)',
                    titleColor: '#111827',
                    bodyColor: '#374151',
                    borderColor: '#22c55e',
                    borderWidth: 2,
                    cornerRadius: 12,
                    callbacks: {
                        label: function(context) {
                            const value = context.parsed;
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = ((value / total) * 100).toFixed(1);
                            return `${context.label}: $${(value/1000).toFixed(0)}K (${percentage}%)`;
                        }
                    }
                }
            },
            animation: {
                animateRotate: true,
                animateScale: true,
                duration: 2000,
                easing: 'easeInOutCubic'
            }
        }
    });
}

// Savings Breakdown Chart - Doughnut Chart  
function initializeSavingsBreakdownChart() {
    const ctx = document.getElementById('savingsBreakdownChart');
    if (!ctx) return;
    
    const chartCtx = ctx.getContext('2d');
    
    new Chart(chartCtx, {
        type: 'doughnut',
        data: {
            labels: ['Node Pools', 'Networking', 'Storage'],
            datasets: [{
                data: [159.98, 26.62, 0], // Values from your screenshot
                backgroundColor: [
                    '#3b82f6', // Blue for Node Pools
                    '#22c55e', // Green for Networking
                    '#6b7280'  // Gray for Storage (0 value)
                ],
                borderColor: chartColors.white,
                borderWidth: 3,
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            aspectRatio: 1.5,
            cutout: '60%',
            plugins: {
                legend: {
                    position: 'right',
                    labels: {
                        usePointStyle: true,
                        pointStyle: 'circle',
                        padding: 15,
                        font: {
                            weight: '600',
                            size: 11
                        },
                        generateLabels: function(chart) {
                            const data = chart.data;
                            if (data.labels.length && data.datasets.length) {
                                return data.labels.map((label, i) => {
                                    const value = data.datasets[0].data[i];
                                    const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                                    const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : '0.0';
                                    return {
                                        text: `${label}: $${value.toFixed(2)} (${percentage}%)`,
                                        fillStyle: data.datasets[0].backgroundColor[i],
                                        hidden: false,
                                        index: i
                                    };
                                });
                            }
                            return [];
                        }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(255, 255, 255, 0.95)',
                    titleColor: '#111827',
                    bodyColor: '#374151',
                    borderColor: '#22c55e',
                    borderWidth: 2,
                    cornerRadius: 12,
                    callbacks: {
                        label: function(context) {
                            const value = context.parsed;
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : '0.0';
                            return `${context.label}: $${value.toFixed(2)} (${percentage}%)`;
                        }
                    }
                }
            },
            animation: {
                animateRotate: true,
                animateScale: true,
                duration: 2000,
                easing: 'easeInOutCubic'
            }
        }
    });
}

// Animate counter numbers
function animateCounters() {
    const counters = document.querySelectorAll('.counter');
    
    counters.forEach(counter => {
        const target = parseInt(counter.getAttribute('data-target'));
        const increment = target / 100;
        let current = 0;
        
        const updateCounter = () => {
            if (current < target) {
                current += increment;
                counter.textContent = Math.ceil(current).toLocaleString();
                requestAnimationFrame(updateCounter);
            } else {
                counter.textContent = target.toLocaleString();
            }
        };
        
        // Start animation when element comes into view
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    updateCounter();
                    observer.unobserve(entry.target);
                }
            });
        });
        
        observer.observe(counter);
    });
}

// Initialize scroll animations
function initializeScrollAnimations() {
    const animateElements = document.querySelectorAll('.animate-on-scroll');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry, index) => {
            if (entry.isIntersecting) {
                setTimeout(() => {
                    entry.target.classList.add('animated');
                }, index * 100); // Stagger animation
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    });
    
    animateElements.forEach(el => {
        observer.observe(el);
    });
}

// Add hover effects to chart containers
document.addEventListener('DOMContentLoaded', function() {
    const chartContainers = document.querySelectorAll('.chart-container');
    
    chartContainers.forEach(container => {
        container.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-5px) scale(1.02)';
        });
        
        container.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
});

// Export functions for external use
window.kubeoptCharts = {
    initializeCostTrendsChart,
    initializeNodeUtilizationChart,
    initializeCostDistributionChart,
    initializeSavingsBreakdownChart,
    animateCounters,
    chartColors
};