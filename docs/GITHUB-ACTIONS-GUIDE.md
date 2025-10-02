# GitHub Actions Setup for Kubeopt.com

Complete guide to set up automated deployment to Azure AKS using GitHub Actions.

## Prerequisites

✅ **Azure Infrastructure**: AKS cluster and ACR already deployed via Terraform  
✅ **Service Principal**: Created for GitHub Actions authentication  
✅ **GitHub Repository**: Your kubeopt-com repository  

## GitHub Repository Secrets Setup

You need to add the following secret to your GitHub repository:

### 1. Navigate to Repository Settings
- Go to your GitHub repository
- Click **Settings** → **Secrets and variables** → **Actions**

### 2. Add AZURE_CREDENTIALS Secret

Create a new repository secret with:
- **Name**: `AZURE_CREDENTIALS`
- **Value**: The complete JSON output from your `az ad sp create-for-rbac` command

The JSON should include these fields:
- clientId (your service principal ID)
- clientSecret (your service principal password)  
- subscriptionId (your Azure subscription)
- tenantId (your Azure tenant)
- Plus the standard Azure endpoint URLs

⚠️ **Security Note**: These credentials have limited scope to your resource group only.

## CI/CD Pipeline Overview

The GitHub Actions workflow (`.github/workflows/deploy.yml`) performs these steps:

### 1. **Build Phase**
- ✅ Checkout code
- ✅ Login to Azure
- ✅ Build Docker image with multi-platform support
- ✅ Push to Azure Container Registry

### 2. **Deploy Phase**
- ✅ Get AKS credentials
- ✅ Create namespace if needed
- ✅ Deploy to Kubernetes
- ✅ Wait for rollout completion
- ✅ Show deployment status

### 3. **Optimization Features**
- ✅ **Image caching**: Faster builds using GitHub Actions cache
- ✅ **Multi-platform builds**: Supports ARM64 and AMD64
- ✅ **Automatic tagging**: Uses git SHA and branch names
- ✅ **Cleanup**: Removes old images to save ACR storage costs

## Deployment Configuration

### Resource Optimization (Startup-Friendly)
- **Replicas**: 1 (with HPA scaling 1-3)
- **CPU**: 50m request, 200m limit
- **Memory**: 64Mi request, 256Mi limit
- **Spot Instance Support**: Tolerates spot node evictions

### Auto-Scaling Configuration
- **Min Replicas**: 1
- **Max Replicas**: 3
- **CPU Threshold**: 70%
- **Memory Threshold**: 80%

## Triggering Deployments

### Automatic Deployments
- **Push to main**: Automatically deploys to production
- **Pull Requests**: Builds and validates (no deployment)

### Manual Deployment
- Go to **Actions** tab in GitHub
- Select **Deploy to AKS** workflow
- Click **Run workflow**

## Monitoring Your Deployment

### GitHub Actions Logs
- Check the **Actions** tab for build/deploy status
- View detailed logs for each step

### Kubernetes Commands
```bash
# Get cluster credentials
az aks get-credentials --resource-group rg-kubeopt-com-prod --name aks-kubeopt-com-prod

# Check deployment status
kubectl get pods -n kubeopt-com
kubectl get services -n kubeopt-com
kubectl get ingress -n kubeopt-com

# View logs
kubectl logs -n kubeopt-com deployment/kubeopt-website -f
```

### Azure Portal
- **AKS Cluster**: [View in Azure Portal](https://portal.azure.com/#@/resource/subscriptions/aa6078c8-02d7-459d-a5cb-99da0f7752f2/resourceGroups/rg-kubeopt-com-prod/providers/Microsoft.ContainerService/managedClusters/aks-kubeopt-com-prod)
- **Container Registry**: [View in Azure Portal](https://portal.azure.com/#@/resource/subscriptions/aa6078c8-02d7-459d-a5cb-99da0f7752f2/resourceGroups/rg-kubeopt-com-prod/providers/Microsoft.ContainerRegistry/registries/acrkubeoptioprod)

## Troubleshooting

### Common Issues

**1. Authentication Failed**
- Verify `AZURE_CREDENTIALS` secret is correct
- Check service principal permissions

**2. Image Pull Failed**
- Ensure ACR authentication is working
- Verify image exists in registry

**3. Deployment Timeout**
- Check pod logs: `kubectl describe pod <pod-name> -n kubeopt-com`
- Verify resource requests don't exceed node capacity

**4. Health Check Fails**
- Ensure `/health` endpoint exists in your application
- Check port configuration (5000)

### Debug Commands
```bash
# Check pod events
kubectl describe deployment kubeopt-website -n kubeopt-com

# View recent pod logs
kubectl logs --tail=50 -n kubeopt-com deployment/kubeopt-website

# Check service endpoints
kubectl get endpoints -n kubeopt-com

# Verify ingress configuration
kubectl describe ingress -n kubeopt-com
```

## Cost Optimization Features

- **Spot Instance Support**: Saves 60-80% on compute costs
- **Efficient Resource Limits**: Optimized for startup budgets
- **Image Cleanup**: Automatically removes old images
- **Minimal Replicas**: Starts with 1 pod, scales as needed

## Security Features

- **Non-root containers**: Runs as unprivileged user
- **Secret management**: Uses Kubernetes secrets
- **Network policies**: Configured for secure communication
- **Health checks**: Ensures container health

## Next Steps

1. **Push your code** to trigger first deployment
2. **Configure DNS** in GoDaddy to point to your load balancer
3. **Monitor costs** using Azure Cost Management
4. **Set up alerts** for deployment failures
5. **Configure SSL certificates** using cert-manager

Your CI/CD pipeline is now ready! 🚀