#!/bin/bash

# SSL Certificate Troubleshooting Script for kubeopt.com
# This script helps diagnose and fix SSL certificate issues

set -e

NAMESPACE="kubeopt-com"
CERT_NAME="kubeopt-com-tls"
INGRESS_NAME="kubeopt-website-ingress"

echo "🔒 SSL Certificate Troubleshooting for kubeopt.com"
echo "=================================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check cluster connectivity
echo "📡 Checking cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "💡 Run: az aks get-credentials --resource-group rg-kubeopt-com-prod --name aks-kubeopt-com-prod --admin"
    exit 1
fi
echo "✅ Connected to cluster"

# Check namespace
echo "📂 Checking namespace..."
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "❌ Namespace $NAMESPACE does not exist"
    exit 1
fi
echo "✅ Namespace $NAMESPACE exists"

# Check cert-manager
echo "🔧 Checking cert-manager..."
if ! kubectl get namespace cert-manager &> /dev/null; then
    echo "❌ cert-manager is not installed"
    echo "💡 Installing cert-manager..."
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
    echo "⏳ Waiting for cert-manager to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
    kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
    kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-cainjector -n cert-manager
    echo "✅ cert-manager installed successfully"
else
    echo "✅ cert-manager is installed"
fi

# Check cert-manager pods
echo "🔍 Checking cert-manager pods..."
kubectl get pods -n cert-manager
if ! kubectl get pods -n cert-manager | grep -q "Running"; then
    echo "⚠️ Some cert-manager pods are not running"
    kubectl describe pods -n cert-manager
fi

# Check ingress controller
echo "🌐 Checking NGINX ingress controller..."
if ! kubectl get namespace ingress-nginx &> /dev/null; then
    echo "❌ NGINX ingress controller is not installed"
    echo "💡 Installing NGINX ingress controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
    echo "⏳ Waiting for ingress controller to be ready..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    echo "✅ NGINX ingress controller installed successfully"
else
    echo "✅ NGINX ingress controller is installed"
fi

# Get external IP
echo "🌍 Getting external IP..."
EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
if [ -z "$EXTERNAL_IP" ] || [ "$EXTERNAL_IP" = "null" ]; then
    echo "⚠️ External IP not available yet"
    echo "💡 This is normal for new deployments. Wait a few minutes."
else
    echo "✅ External IP: $EXTERNAL_IP"
fi

# Check LimitRange
echo "📊 Checking resource limits..."
if kubectl get limitrange -n $NAMESPACE &> /dev/null; then
    echo "📋 Current LimitRange:"
    kubectl describe limitrange -n $NAMESPACE
    
    # Check if CPU minimum is compatible with cert-manager
    CPU_MIN=$(kubectl get limitrange -n $NAMESPACE -o jsonpath='{.items[0].spec.limits[0].min.cpu}' 2>/dev/null || echo "")
    if [ ! -z "$CPU_MIN" ]; then
        CPU_MIN_VALUE=$(echo $CPU_MIN | sed 's/m//')
        if [ "$CPU_MIN_VALUE" -gt "10" ]; then
            echo "⚠️ CPU minimum ($CPU_MIN) may be too high for cert-manager HTTP solver (needs 10m)"
            echo "💡 Consider reducing CPU minimum to 10m in namespace.yaml"
        else
            echo "✅ CPU minimum ($CPU_MIN) is compatible with cert-manager"
        fi
    fi
fi

# Check certificates
echo "🔒 Checking SSL certificates..."
if kubectl get certificate $CERT_NAME -n $NAMESPACE &> /dev/null; then
    echo "📋 Certificate status:"
    kubectl get certificate $CERT_NAME -n $NAMESPACE
    kubectl describe certificate $CERT_NAME -n $NAMESPACE
    
    # Check if certificate is ready
    CERT_READY=$(kubectl get certificate $CERT_NAME -n $NAMESPACE -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "False")
    if [ "$CERT_READY" = "True" ]; then
        echo "✅ SSL certificate is ready!"
    else
        echo "⚠️ SSL certificate is not ready"
        
        # Check challenges
        echo "🔍 Checking ACME challenges..."
        if kubectl get challenges -n $NAMESPACE &> /dev/null; then
            kubectl get challenges -n $NAMESPACE
            echo "📋 Challenge details:"
            kubectl describe challenges -n $NAMESPACE
        else
            echo "ℹ️ No active challenges"
        fi
        
        # Check cert-manager logs
        echo "📜 Recent cert-manager logs:"
        kubectl logs -n cert-manager deployment/cert-manager --tail=10 | head -20
    fi
else
    echo "❌ Certificate $CERT_NAME does not exist"
    echo "💡 Certificate should be created automatically by ingress annotations"
fi

# Check ingress
echo "🌐 Checking ingress..."
if kubectl get ingress $INGRESS_NAME -n $NAMESPACE &> /dev/null; then
    echo "📋 Ingress status:"
    kubectl get ingress $INGRESS_NAME -n $NAMESPACE
    kubectl describe ingress $INGRESS_NAME -n $NAMESPACE
else
    echo "❌ Ingress $INGRESS_NAME does not exist"
fi

# DNS checks
if [ ! -z "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
    echo "🌐 Checking DNS resolution..."
    
    echo "📍 kubeopt.com DNS resolution:"
    nslookup kubeopt.com 8.8.8.8 || echo "DNS resolution failed"
    
    echo "📍 www.kubeopt.com DNS resolution:"
    nslookup www.kubeopt.com 8.8.8.8 || echo "DNS resolution failed"
    
    # Test HTTP connectivity
    echo "🔗 Testing HTTP connectivity..."
    if curl -I -H "Host: kubeopt.com" http://$EXTERNAL_IP --max-time 10 &> /dev/null; then
        echo "✅ HTTP connectivity working"
    else
        echo "❌ HTTP connectivity failed"
    fi
    
    # Test HTTPS connectivity
    echo "🔒 Testing HTTPS connectivity..."
    if curl -k -I -H "Host: kubeopt.com" https://$EXTERNAL_IP --max-time 10 &> /dev/null; then
        echo "✅ HTTPS connectivity working"
        
        # Test SSL certificate
        echo "🔍 Testing SSL certificate..."
        if curl -I -H "Host: kubeopt.com" https://$EXTERNAL_IP --max-time 10 &> /dev/null; then
            echo "✅ SSL certificate is valid!"
        else
            echo "⚠️ SSL certificate has issues (certificate may still be generating)"
        fi
    else
        echo "❌ HTTPS connectivity failed"
    fi
fi

echo ""
echo "=================================================="
echo "🔧 TROUBLESHOOTING ACTIONS:"
echo "=================================================="

# Suggest fixes based on findings
if [ "$CERT_READY" != "True" ]; then
    echo "🔄 To force certificate renewal:"
    echo "   kubectl delete certificate $CERT_NAME -n $NAMESPACE"
    echo "   kubectl delete challenges --all -n $NAMESPACE"
    echo "   kubectl annotate ingress $INGRESS_NAME -n $NAMESPACE cert-manager.io/cluster-issuer=letsencrypt-prod --overwrite"
    echo ""
fi

if [ -z "$EXTERNAL_IP" ] || [ "$EXTERNAL_IP" = "null" ]; then
    echo "⏳ Waiting for external IP:"
    echo "   kubectl get svc ingress-nginx-controller -n ingress-nginx -w"
    echo ""
fi

echo "📊 Monitor certificate status:"
echo "   kubectl get certificates -n $NAMESPACE -w"
echo ""

echo "📜 Check cert-manager logs:"
echo "   kubectl logs -f -n cert-manager deployment/cert-manager"
echo ""

echo "🌐 Update DNS to point to external IP:"
echo "   kubeopt.com    A    $EXTERNAL_IP"
echo "   www.kubeopt.com A   $EXTERNAL_IP"
echo ""

echo "🔒 SSL Certificate Troubleshooting Complete!"