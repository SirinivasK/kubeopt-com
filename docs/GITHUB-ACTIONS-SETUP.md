# GitHub Actions CI/CD Setup Guide

This guide will help you set up automated deployments for the kubeopt.com website using GitHub Actions.

## 🎯 What Gets Automated

The GitHub Actions workflow will automatically:

1. **Build Docker Image** - Multi-platform build for AMD64 architecture
2. **Push to Azure Container Registry** - Automated image tagging and registry push
3. **Deploy to AKS** - Complete Kubernetes deployment
4. **Install Dependencies** - NGINX Ingress Controller, cert-manager
5. **Manage Secrets** - Kubernetes secrets creation/updates
6. **Health Checks** - Comprehensive deployment verification
7. **DNS Information** - Provides external IP for DNS configuration

## 🔧 Required GitHub Secrets

You need to set up these secrets in your GitHub repository:

### 1. Azure Service Principal

Create an Azure Service Principal with appropriate permissions:

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "github-actions-kubeopt" \
  --role "Contributor" \
  --scopes "/subscriptions/aa6078c8-02d7-459d-a5cb-99da0f7752f2" \
  --sdk-auth
```

This will output JSON like:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "aa6078c8-02d7-459d-a5cb-99da0f7752f2",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### 2. Additional Role Assignments

Grant additional permissions for AKS and ACR:

```bash
# Get service principal object ID
SP_ID=$(az ad sp list --display-name "github-actions-kubeopt" --query "[0].id" -o tsv)

# Grant AKS Cluster Admin role
az role assignment create \
  --assignee $SP_ID \
  --role "Azure Kubernetes Service Cluster Admin Role" \
  --scope "/subscriptions/aa6078c8-02d7-459d-a5cb-99da0f7752f2/resourceGroups/rg-kubeopt-com-prod/providers/Microsoft.ContainerService/managedClusters/aks-kubeopt-com-prod"

# Grant ACR Push role
az role assignment create \
  --assignee $SP_ID \
  --role "AcrPush" \
  --scope "/subscriptions/aa6078c8-02d7-459d-a5cb-99da0f7752f2/resourceGroups/rg-kubeopt-com-prod/providers/Microsoft.ContainerRegistry/registries/acrkubeoptioprod"
```

## 📝 GitHub Repository Secrets

Add these secrets to your GitHub repository (`Settings` → `Secrets and variables` → `Actions`):

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AZURE_CREDENTIALS_PROD` | Full JSON from service principal creation | Azure authentication |
| `FLASK_SECRET_KEY` | `S46Deu5pqZfb-ihJnmCKHG2SDbKDp0AiYChcV93lx68` | Flask secret key for sessions |

### How to Add Secrets:

1. Go to your GitHub repository
2. Click `Settings` → `Secrets and variables` → `Actions`
3. Click `New repository secret`
4. Add each secret with the exact name and value

## 🚀 Workflow Triggers

The workflow runs on:

- **Push to main branch** - Automatic deployment to production
- **Pull requests** - Build and test (no deployment)
- **Manual trigger** - Via GitHub Actions web interface

## 📊 Deployment Process

### Automatic Steps:

1. **Code Checkout** - Gets latest code from repository
2. **Azure Login** - Authenticates with Azure using service principal
3. **Docker Build** - Builds AMD64 image with proper tags
4. **Registry Push** - Pushes to Azure Container Registry
5. **AKS Connection** - Gets cluster credentials
6. **Infrastructure Setup**:
   - Creates namespace if needed
   - Installs NGINX Ingress Controller
   - Installs cert-manager for SSL
   - Creates/updates Kubernetes secrets
7. **Application Deployment**:
   - Updates deployment with new image
   - Applies all Kubernetes manifests
   - Waits for deployment to be ready
8. **Verification**:
   - Health checks
   - Service status
   - External IP information
   - Website functionality tests

### Manual Steps Eliminated:

✅ Docker image building and tagging  
✅ ACR login and image push  
✅ Kubernetes secret creation  
✅ NGINX Ingress Controller installation  
✅ Application deployment  
✅ Health checks and verification  

## 🔍 Monitoring Deployments

### Via GitHub Actions:

1. Go to your repository → `Actions` tab
2. Click on the latest workflow run
3. View real-time logs and status

### Key Information Provided:

- **Build Status** - Docker image build success/failure
- **Deployment Status** - Kubernetes deployment progress
- **External IP** - For DNS configuration
- **Health Check Results** - Website functionality verification
- **Pod Status** - Kubernetes pod health

## 🌐 DNS Configuration

The workflow will output the external IP address. Use this to update your GoDaddy DNS:

```
Type: A
Name: @
Value: [EXTERNAL_IP_FROM_WORKFLOW]
TTL: 1 Hour

Type: A  
Name: www
Value: [EXTERNAL_IP_FROM_WORKFLOW]
TTL: 1 Hour
```

## 🛠 Troubleshooting

### Common Issues:

#### 1. Azure Authentication Failed
```
Error: AADSTS70002: Error validating credentials
```
**Solution**: Check `AZURE_CREDENTIALS_PROD` secret format and service principal permissions

#### 2. ACR Login Failed
```
Error: unauthorized: authentication required
```
**Solution**: Ensure service principal has `AcrPush` role on the container registry

#### 3. AKS Access Denied
```
Error: User does not have access to the resource
```
**Solution**: Ensure service principal has `Azure Kubernetes Service Cluster Admin Role`

#### 4. Image Pull Failed
```
Error: ImagePullBackOff
```
**Solution**: Check if image was pushed successfully to ACR and deployment.yaml image reference

#### 5. Health Check Failed
```
Error: curl: (7) Failed to connect
```
**Solution**: Wait for load balancer to assign external IP (can take 5-10 minutes)

### Debug Commands:

Add these to a manual workflow run for debugging:

```bash
# Check service principal permissions
az role assignment list --assignee $SP_ID --output table

# Check ACR access
az acr repository list --name acrkubeoptioprod

# Check AKS access
kubectl get nodes

# Check deployment status
kubectl describe deployment kubeopt-website -n kubeopt-com

# Check ingress controller
kubectl get svc -n ingress-nginx
```

## 🔄 Manual Deployment Override

If you need to deploy manually while maintaining the automated process:

```bash
# Build and push image manually
docker buildx build --platform linux/amd64 -t acrkubeoptioprod.azurecr.io/kubeopt-com:manual .
docker push acrkubeoptioprod.azurecr.io/kubeopt-com:manual

# Update deployment manually
kubectl set image deployment/kubeopt-website kubeopt-website=acrkubeoptioprod.azurecr.io/kubeopt-com:manual -n kubeopt-com
```

## 📈 Performance Optimizations

The workflow includes several optimizations:

- **Docker Build Cache** - Uses GitHub Actions cache for faster builds
- **Parallel Steps** - Multiple independent operations run concurrently
- **Smart Waits** - Only waits for necessary conditions
- **Image Cleanup** - Removes old images to save ACR storage costs
- **Conditional Steps** - Skips unnecessary installations if already present

## 🔐 Security Best Practices

- Service principal follows principle of least privilege
- Secrets are stored securely in GitHub
- Images are scanned during build process
- Non-root container execution
- Read-only root filesystem where possible
- Network policies and security contexts applied

---

## ✅ **Next Steps**

1. **Add the GitHub secrets** as described above
2. **Commit and push** your changes to trigger the first automated deployment
3. **Monitor the workflow** in GitHub Actions
4. **Update DNS** with the external IP provided in the workflow output
5. **Verify** your website is accessible at https://kubeopt.com

Your deployment will now be fully automated! 🎉