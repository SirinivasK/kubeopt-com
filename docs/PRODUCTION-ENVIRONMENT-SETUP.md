# Production Environment Setup Guide

## 🎯 Overview

This guide walks you through setting up the GitHub production environment with deployment approval and proper secrets management.

## 📋 Step 1: Create Production Environment

1. **Navigate to Repository Settings**:
   - Go to: https://github.com/SirinivasK/kubeopt-com/settings/environments
   - Click **"New environment"**

2. **Create Production Environment**:
   - **Environment name**: `production`
   - **Configure protection rules**:
     - ✅ **Required reviewers**: Add yourself as a reviewer
     - ✅ **Wait timer**: 0 minutes (optional: add delay)
     - ✅ **Deployment branches**: Only `main` branch
   - Click **"Configure environment"**

## 🔐 Step 2: Add Environment Secrets

In the **production** environment, add these secrets:

### AZURE_CREDENTIALS_PROD
- **Name**: `AZURE_CREDENTIALS_PROD`
- **Value**: The JSON output from your Azure service principal creation

Use the exact JSON output from the `az ad sp create-for-rbac` command you ran earlier. It should include:
- clientId (your service principal ID)
- clientSecret (your service principal secret)
- subscriptionId (your Azure subscription) 
- tenantId (your Azure tenant)
- Plus the standard Azure endpoint URLs

## 🚀 Step 3: Test Deployment Flow

### Automatic Trigger
1. **Push to main branch** (like this commit)
2. **GitHub Actions will start** but wait for approval
3. **Go to Actions tab**: https://github.com/SirinivasK/kubeopt-com/actions
4. **Click on the pending deployment**
5. **Review and approve** the deployment

### Manual Trigger
1. **Go to Actions**: https://github.com/SirinivasK/kubeopt-com/actions
2. **Select "Deploy to AKS" workflow**
3. **Click "Run workflow"**
4. **Select main branch** and run
5. **Approve when prompted**

## 🛡️ Security Features Enabled

### Environment Protection
- ✅ **Manual approval required** for all production deployments
- ✅ **Branch restriction** - only main branch can deploy to production
- ✅ **Environment-specific secrets** - isolated from other environments
- ✅ **Deployment history** - track who approved what and when

### Deployment Process
1. **Code pushed** to main branch
2. **Workflow starts** and builds Docker image
3. **Approval required** - workflow pauses and waits
4. **Reviewer approves** - deployment continues to Azure
5. **Health checks** verify successful deployment

## 📊 Monitoring Production Deployments

### GitHub Actions Dashboard
- **Workflow runs**: https://github.com/SirinivasK/kubeopt-com/actions
- **Environment deployments**: https://github.com/SirinivasK/kubeopt-com/deployments
- **Protection logs**: Track approval history

### Azure Monitoring
- **AKS Cluster**: [Azure Portal](https://portal.azure.com/#@/resource/subscriptions/aa6078c8-02d7-459d-a5cb-99da0f7752f2/resourceGroups/rg-kubeopt-com-prod/providers/Microsoft.ContainerService/managedClusters/aks-kubeopt-com-prod)
- **Container Registry**: [ACR Portal](https://portal.azure.com/#@/resource/subscriptions/aa6078c8-02d7-459d-a5cb-99da0f7752f2/resourceGroups/rg-kubeopt-com-prod/providers/Microsoft.ContainerRegistry/registries/acrkubeoptioprod)

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

## 🚨 Emergency Procedures

### Rollback Deployment
```bash
# Rollback to previous version
kubectl rollout undo deployment/kubeopt-website -n kubeopt-com

# Check rollout status
kubectl rollout status deployment/kubeopt-website -n kubeopt-com
```

### Stop Traffic
```bash
# Scale down to 0 replicas (emergency stop)
kubectl scale deployment kubeopt-website --replicas=0 -n kubeopt-com

# Scale back up
kubectl scale deployment kubeopt-website --replicas=1 -n kubeopt-com
```

## 📝 Next Steps

Once production environment is set up:

1. **Test the approval flow** with a small change
2. **Configure staging environment** for testing
3. **Set up development environment** for feature development
4. **Add more reviewers** for production approvals
5. **Configure branch protection rules** for additional security

## 🔗 Useful Links

- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

Your production environment is now secure and ready for controlled deployments! 🎯