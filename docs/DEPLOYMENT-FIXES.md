# Deployment Fixes Documentation

## Overview
This document details the fixes applied to resolve the kubeopt-com deployment issues in the Azure Kubernetes Service (AKS) cluster.

## Initial Problem
The deployment was timing out with the error:
```
error: timed out waiting for the condition on deployments/kubeopt-website
Error: Process completed with exit code 1.
```

## Root Cause Analysis
Upon investigation, several issues were identified:

1. **Invalid Image Reference**: The deployment.yaml contained a placeholder `{{IMAGE_TAG}}` instead of a valid Docker image
2. **Architecture Mismatch**: Initial Docker image was built for ARM64 (Apple Silicon) but AKS cluster runs on AMD64
3. **Missing Kubernetes Secret**: The `kubeopt-secrets` secret was not created in the cluster
4. **Container Permissions**: File system permission issues preventing database file creation
5. **SSL Certificate Generation**: LimitRange CPU minimum blocking cert-manager HTTP solver

## Fixes Applied

### 1. Container Image Build and Registry
**Problem**: Invalid image tag and missing container registry setup

**Solution**:
- Built proper Docker image for AMD64 architecture
- Tagged image for Azure Container Registry (ACR)
- Pushed image to ACR: `acrkubeoptioprod.azurecr.io/kubeopt-com:amd64`

**Commands executed**:
```bash
# Login to ACR
az acr login --name acrkubeoptioprod

# Build AMD64 image
docker buildx build --platform linux/amd64 -t kubeopt-website:amd64 .

# Tag for ACR
docker tag kubeopt-website:amd64 acrkubeoptioprod.azurecr.io/kubeopt-com:amd64

# Push to ACR
docker push acrkubeoptioprod.azurecr.io/kubeopt-com:amd64
```

### 2. Kubernetes Secret Creation
**Problem**: Missing `kubeopt-secrets` secret causing CreateContainerConfigError

**Solution**: Created the required secret with a secure Flask secret key

**Commands executed**:
```bash
# Generate secure secret key
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Create Kubernetes secret
kubectl create secret generic kubeopt-secrets \
  --namespace=kubeopt-com \
  --from-literal=secret-key=S46Deu5pqZfb-ihJnmCKHG2SDbKDp0AiYChcV93lx68
```

### 3. Deployment Configuration Updates
**Problem**: Various configuration issues in deployment.yaml

**Solution**: Updated deployment.yaml with the following changes:

#### Image Reference
```yaml
# Before
image: {{IMAGE_TAG}}

# After
image: acrkubeoptioprod.azurecr.io/kubeopt-com:amd64
```

#### Security Context
```yaml
# Before
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  capabilities:
    drop:
    - ALL
    add:
    - NET_BIND_SERVICE

# After
securityContext:
  runAsUser: 0
  runAsGroup: 0
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  capabilities:
    drop:
    - ALL
```

### 4. Dockerfile Improvements
**Problem**: Missing dependencies for health checks

**Solution**: Added `curl` package to Dockerfile for health check functionality

```dockerfile
# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*
```

### 5. SSL Certificate Automation
**Problem**: SSL certificate generation failing due to resource constraints

**Solution**: Fixed LimitRange and enhanced automation

#### LimitRange Fix
```yaml
# Before
min:
  cpu: 50m
  memory: 64Mi

# After  
min:
  cpu: 10m  # Allows cert-manager HTTP solver
  memory: 64Mi
```

#### Enhanced GitHub Actions
- **Automated cert-manager installation**
- **SSL certificate status monitoring**
- **ACME challenge troubleshooting**
- **Automatic certificate renewal on failures**
- **Comprehensive SSL health checks**

## Current Status
✅ **Deployment Successful**: Pod is now running (1/1 Ready)  
✅ **SSL Certificates**: Let's Encrypt certificates working  
✅ **HTTPS Access**: https://kubeopt.com and https://www.kubeopt.com  

```bash
kubectl get pods -n kubeopt-com
NAME                               READY   STATUS    RESTARTS   AGE
kubeopt-website-55c88f59cd-v2dpd   1/1     Running   0          45s

kubectl get certificates -n kubeopt-com
NAME              READY   SECRET            AGE
kubeopt-com-tls   True    kubeopt-com-tls   15m
```

## Files Modified
1. `k8s/deployment.yaml` - Updated image reference and security context
2. `k8s/namespace.yaml` - Fixed LimitRange CPU minimum for cert-manager (50m → 10m)
3. `.github/workflows/deploy.yml` - Enhanced with SSL certificate automation
4. `scripts/ssl-troubleshoot.sh` - Added SSL troubleshooting script
5. `Dockerfile` - Added curl dependency for health checks

## Security Considerations
**Note**: The current fix runs the container as root (UID 0) to resolve permission issues with the persistent volume. For production environments, consider:

1. **Init Container**: Use an init container to fix volume permissions
2. **Security Context Constraints**: Configure proper volume ownership
3. **Pod Security Standards**: Implement restricted pod security standards

## Future Improvements
1. **CI/CD Pipeline**: Implement automated image builds and deployments
2. **Image Versioning**: Use proper semantic versioning for container images
3. **Secret Management**: Use Azure Key Vault or similar for secret management
4. **Security Hardening**: Implement proper non-root user with volume permissions

## Verification Commands
```bash
# Check deployment status
kubectl get deployment -n kubeopt-com

# Check pod status
kubectl get pods -n kubeopt-com

# Check pod logs
kubectl logs -f deployment/kubeopt-website -n kubeopt-com

# Check service endpoints
kubectl get svc -n kubeopt-com

# Test application health
kubectl port-forward svc/kubeopt-website 8080:80 -n kubeopt-com
# Then visit http://localhost:8080/health
```

## Rollback Instructions
If issues arise, rollback using:
```bash
# Rollback deployment
kubectl rollout undo deployment/kubeopt-website -n kubeopt-com

# Check rollback status
kubectl rollout status deployment/kubeopt-website -n kubeopt-com
```

---
**Generated**: October 2, 2025  
**Author**: Claude Code Assistant  
**Status**: Deployment Successful