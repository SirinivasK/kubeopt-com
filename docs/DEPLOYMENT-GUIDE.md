# kubeopt.com Deployment Guide

Complete guide for deploying the kubeopt.com website to Azure AKS with Terraform and GitHub Actions.

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│   GitHub Actions │───▶│   Azure AKS     │
│                 │    │                  │    │                 │
│ - Source Code   │    │ - CI/CD Pipeline │    │ - Kubernetes    │
│ - Terraform     │    │ - Build & Test   │    │ - Load Balancer │
│ - K8s Manifests │    │ - Security Scan  │    │ - SSL Certs     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GoDaddy DNS   │───▶│   Azure LB IP    │───▶│   Users         │
│                 │    │                  │    │                 │
│ - A Record      │    │ - Static IP      │    │ - kubeopt.com  │
│ - CNAME Record  │    │ - SSL Termination│    │ - HTTPS Access  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Prerequisites

### 1. Azure Account Setup
- Azure subscription with Owner or Contributor role
- Azure CLI installed and configured
- Service Principal for Terraform and GitHub Actions

### 2. GitHub Repository Setup
- Fork or clone the kubeopt-com repository
- Configure GitHub Secrets (see below)

### 3. Domain Setup
- Domain purchased from GoDaddy: `kubeopt.com`
- Access to GoDaddy DNS management

### 4. Tools Required
```bash
# Install required tools
az --version                    # Azure CLI
terraform --version            # Terraform
kubectl version --client       # Kubernetes CLI
docker --version              # Docker
helm version                  # Helm
```

## Step 1: Azure Infrastructure Setup

### Create Service Principal

```bash
# Create service principal for Terraform
az ad sp create-for-rbac \
  --name "sp-kubeopt-terraform" \
  --role "Owner" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --sdk-auth

# Save the output - you'll need it for GitHub Secrets
```

### Create Storage Account for Terraform State

```bash
# Create resource group for Terraform state
az group create \
  --name "rg-kubeopt-terraform-state" \
  --location "West Europe"

# Create storage account
az storage account create \
  --name "stkubeopttfstate" \
  --resource-group "rg-kubeopt-terraform-state" \
  --location "West Europe" \
  --sku "Standard_LRS"

# Create container for state files
az storage container create \
  --name "tfstate" \
  --account-name "stkubeopttfstate"
```

## Step 2: GitHub Secrets Configuration

Add the following secrets to your GitHub repository (`Settings` → `Secrets and variables` → `Actions`):

### Azure Authentication
```
ARM_CLIENT_ID=your_service_principal_app_id
ARM_CLIENT_SECRET=your_service_principal_password
ARM_SUBSCRIPTION_ID=your_azure_subscription_id
ARM_TENANT_ID=your_azure_tenant_id

AZURE_CREDENTIALS={
  "clientId": "your_service_principal_app_id",
  "clientSecret": "your_service_principal_password",
  "subscriptionId": "your_azure_subscription_id",
  "tenantId": "your_azure_tenant_id"
}
```

### Terraform State Storage
```
TF_STATE_RESOURCE_GROUP=rg-kubeopt-terraform-state
TF_STATE_STORAGE_ACCOUNT=stkubeopttfstate
TF_STATE_CONTAINER=tfstate
```

### Application Secrets
```
FLASK_SECRET_KEY=your_flask_secret_key_here
MAIL_USERNAME=your_smtp_username
MAIL_PASSWORD=your_smtp_password
ACR_USERNAME=your_acr_username
ACR_PASSWORD=your_acr_password
```

### Generate Flask Secret Key
```python
# Run this to generate a secure secret key
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

## Step 3: Deploy Infrastructure with Terraform

### Option A: Deploy via GitHub Actions (Recommended)

1. **Push Terraform Changes**:
   ```bash
   git add terraform/
   git commit -m "Add Terraform infrastructure"
   git push origin main
   ```

2. **Trigger Terraform Workflow**:
   - Go to GitHub Actions tab
   - Run "Terraform Infrastructure" workflow
   - Select "apply" action

### Option B: Deploy Locally

1. **Configure Terraform Variables**:
   ```bash
   cd terraform/
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize and Apply**:
   ```bash
   # Initialize Terraform
   terraform init \
     -backend-config="resource_group_name=rg-kubeopt-terraform-state" \
     -backend-config="storage_account_name=stkubeopttfstate" \
     -backend-config="container_name=tfstate" \
     -backend-config="key=kubeopt-com.tfstate"
   
   # Plan deployment
   terraform plan
   
   # Apply changes
   terraform apply
   ```

3. **Save Important Outputs**:
   ```bash
   # Get static IP for DNS configuration
   terraform output public_ip_address
   
   # Get AKS credentials
   terraform output kubectl_commands
   
   # Get ACR login server
   terraform output acr_login_server
   ```

## Step 4: Configure DNS

Follow the [GoDaddy DNS Configuration Guide](./GODADDY-DNS-CONFIGURATION.md) to:

1. Get your Azure static IP address
2. Configure A and CNAME records in GoDaddy
3. Wait for DNS propagation (5-30 minutes)

## Step 5: Build and Deploy Application

### Option A: Deploy via GitHub Actions (Recommended)

1. **Configure ACR Credentials**:
   ```bash
   # Get ACR credentials from Terraform output
   terraform output acr_admin_username
   terraform output acr_admin_password
   
   # Add these to GitHub Secrets as:
   # ACR_USERNAME=xxx
   # ACR_PASSWORD=xxx
   ```

2. **Trigger CI/CD Pipeline**:
   ```bash
   git add .
   git commit -m "Deploy kubeopt.com website"
   git push origin main
   ```

### Option B: Deploy Manually

1. **Build and Push Docker Image**:
   ```bash
   # Get AKS credentials
   az aks get-credentials \
     --resource-group rg-kubeopt-com \
     --name aks-kubeopt-com
   
   # Login to ACR
   az acr login --name acrkubeoptio
   
   # Build and push image
   docker build -t acrkubeoptio.azurecr.io/kubeopt-com:latest .
   docker push acrkubeoptio.azurecr.io/kubeopt-com:latest
   ```

2. **Deploy to Kubernetes**:
   ```bash
   # Create secrets
   kubectl create secret generic kubeopt-secrets \
     --from-literal=secret-key="YOUR_FLASK_SECRET_KEY" \
     --from-literal=mail-username="YOUR_SMTP_USERNAME" \
     --from-literal=mail-password="YOUR_SMTP_PASSWORD" \
     --namespace=kubeopt-com
   
   # Deploy all manifests
   kubectl apply -f k8s/
   
   # Wait for deployment
   kubectl rollout status deployment/kubeopt-website -n kubeopt-com
   ```

## Step 6: Verify Deployment

### Check Kubernetes Resources
```bash
# Check namespace
kubectl get namespace kubeopt-com

# Check pods
kubectl get pods -n kubeopt-com

# Check services
kubectl get services -n kubeopt-com

# Check ingress
kubectl get ingress -n kubeopt-com

# Check certificates
kubectl get certificates -n kubeopt-com
```

### Test Website Access
```bash
# Test HTTP (should redirect to HTTPS)
curl -I http://kubeopt.com

# Test HTTPS
curl -I https://kubeopt.com

# Test health endpoint
curl https://kubeopt.com/health
```

### Monitor Logs
```bash
# Application logs
kubectl logs -n kubeopt-com deployment/kubeopt-website -f

# Ingress controller logs
kubectl logs -n ingress-nginx deployment/nginx-ingress-controller -f

# Cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager -f
```

## Step 7: Post-Deployment Configuration

### 1. Enable Monitoring
```bash
# Check Azure Monitor integration
az aks show \
  --resource-group rg-kubeopt-com \
  --name aks-kubeopt-com \
  --query "addonProfiles.omsagent"
```

### 2. Set Up Alerts
Configure Azure Monitor alerts for:
- Pod memory/CPU usage
- Certificate expiration
- Website availability
- Error rates

### 3. Configure Backup
```bash
# Enable backup for persistent volumes
kubectl apply -f - <<EOF
apiVersion: backup.coreos.com/v1
kind: Backup
metadata:
  name: kubeopt-backup
  namespace: kubeopt-com
spec:
  storageLocation: azure-backup
  includedNamespaces:
  - kubeopt-com
  schedule: "0 2 * * *"  # Daily at 2 AM
EOF
```

## Monitoring and Maintenance

### Regular Tasks

#### Daily
- Check website availability
- Review error logs
- Monitor resource usage

#### Weekly
- Review security updates
- Check certificate status
- Analyze traffic patterns

#### Monthly
- Update dependencies
- Review costs
- Test backup/restore procedures

### Key Metrics to Monitor

1. **Application Metrics**
   - Response time
   - Error rate
   - Request volume
   - User sessions

2. **Infrastructure Metrics**
   - CPU/Memory usage
   - Disk usage
   - Network throughput
   - Pod restart count

3. **Security Metrics**
   - Failed authentication attempts
   - SSL certificate expiration
   - Security scan results
   - Vulnerability reports

### Cost Optimization

Your deployment includes several cost optimization features:

- **Spot Instances**: 60-90% cost savings on compute
- **Auto-scaling**: Scales down during low traffic
- **Right-sized VMs**: Optimized VM sizes for workload
- **Storage Optimization**: Premium SSD only where needed

Monitor costs in Azure Cost Management and adjust as needed.

## Troubleshooting Guide

### Common Issues

#### 1. DNS Not Resolving
```bash
# Check DNS propagation
nslookup kubeopt.com
dig kubeopt.com A

# Verify GoDaddy configuration
# Wait 24-48 hours for full propagation
```

#### 2. SSL Certificate Issues
```bash
# Check certificate status
kubectl describe certificate kubeopt-com-tls -n kubeopt-com

# Delete and recreate certificate
kubectl delete certificate kubeopt-com-tls -n kubeopt-com
kubectl apply -f k8s/ingress.yaml
```

#### 3. Pod Crashes
```bash
# Check pod logs
kubectl logs -n kubeopt-com deployment/kubeopt-website

# Check resource usage
kubectl top pods -n kubeopt-com

# Check events
kubectl get events -n kubeopt-com --sort-by='.lastTimestamp'
```

#### 4. Image Pull Errors
```bash
# Check ACR connectivity
az acr check-health --name acrkubeoptio

# Verify image exists
az acr repository list --name acrkubeoptio

# Check secret
kubectl get secret acr-secret -n kubeopt-com -o yaml
```

### Support Resources

- **Azure Support**: https://azure.microsoft.com/support/
- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Terraform Documentation**: https://www.terraform.io/docs/
- **NGINX Ingress**: https://kubernetes.github.io/ingress-nginx/
- **cert-manager**: https://cert-manager.io/docs/

## Security Best Practices

1. **Regular Updates**
   - Keep Kubernetes version updated
   - Update container base images
   - Update dependencies

2. **Access Control**
   - Use RBAC for Kubernetes access
   - Limit Azure permissions
   - Regular access reviews

3. **Network Security**
   - Network policies enabled
   - Private endpoints where possible
   - Regular security scans

4. **Data Protection**
   - Encrypt data at rest
   - Secure secrets management
   - Regular backups

## Next Steps

After successful deployment:

1. **Performance Optimization**
   - Configure CDN (Azure Front Door)
   - Optimize images and assets
   - Enable caching

2. **Enhanced Monitoring**
   - Set up Application Insights
   - Configure custom dashboards
   - Implement alerting

3. **Additional Features**
   - Add staging environment
   - Implement blue-green deployments
   - Set up disaster recovery

4. **Business Growth**
   - Scale infrastructure as needed
   - Add multiple regions
   - Implement advanced security features

---

🎉 **Congratulations!** Your kubeopt.com website is now running on Azure AKS with enterprise-grade features, security, and scalability.