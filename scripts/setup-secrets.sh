#!/bin/bash
# Setup Kubernetes secrets for kubeopt.com deployment
# This script helps generate secrets.yaml from the template

set -e

echo "🔐 Setting up Kubernetes secrets for kubeopt.com..."

# Check if template exists
if [ ! -f "k8s/secrets.yaml.template" ]; then
    echo "❌ Error: secrets.yaml.template not found"
    exit 1
fi

# Generate secret key if not provided
if [ -z "$SECRET_KEY" ]; then
    echo "🔑 Generating Flask secret key..."
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
fi

# Base64 encode the secret key
SECRET_KEY_B64=$(echo -n "$SECRET_KEY" | base64)

# Admin email (default)
ADMIN_EMAIL="admin@kubeopt.com"
ADMIN_EMAIL_B64=$(echo -n "$ADMIN_EMAIL" | base64)

# Create secrets.yaml from template
echo "📝 Creating secrets.yaml from template..."
cp k8s/secrets.yaml.template k8s/secrets.yaml

# Replace placeholders
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/REPLACE_WITH_BASE64_ENCODED_SECRET_KEY/$SECRET_KEY_B64/g" k8s/secrets.yaml
    sed -i '' "s/YWRtaW5Aa3ViZW9wdC5jb20=/$ADMIN_EMAIL_B64/g" k8s/secrets.yaml
else
    # Linux
    sed -i "s/REPLACE_WITH_BASE64_ENCODED_SECRET_KEY/$SECRET_KEY_B64/g" k8s/secrets.yaml
    sed -i "s/YWRtaW5Aa3ViZW9wdC5jb20=/$ADMIN_EMAIL_B64/g" k8s/secrets.yaml
fi

echo "✅ secrets.yaml created successfully!"
echo ""
echo "⚠️  IMPORTANT NOTES:"
echo "   - secrets.yaml contains sensitive data and is not tracked by Git"
echo "   - Deploy secrets before deploying the application:"
echo "     kubectl apply -f k8s/secrets.yaml"
echo "   - For production, consider using Azure Key Vault or Kubernetes secrets management"
echo ""
echo "🔧 Next steps:"
echo "   1. Review and customize k8s/secrets.yaml"
echo "   2. Add any additional secrets (SMTP credentials, etc.)"
echo "   3. Deploy: kubectl apply -f k8s/secrets.yaml"
echo ""

# Show what needs to be manually configured
echo "🔄 Still need to configure manually:"
echo "   - SMTP username/password (if using email features)"
echo "   - External database URL (if not using SQLite)"
echo ""

# Option to apply immediately
read -p "🚀 Apply secrets to Kubernetes now? (y/N): " apply_now
if [[ $apply_now =~ ^[Yy]$ ]]; then
    echo "🎯 Applying secrets to Kubernetes..."
    kubectl apply -f k8s/secrets.yaml
    echo "✅ Secrets applied successfully!"
else
    echo "💡 Remember to apply secrets manually: kubectl apply -f k8s/secrets.yaml"
fi

echo "🎉 Secret setup complete!"