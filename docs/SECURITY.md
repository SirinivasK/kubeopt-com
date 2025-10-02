# Security Guide for Kubeopt.com

## 🔒 Overview

This document outlines security practices and configurations for the kubeopt.com project.

## 🚫 Files Never to Commit

The following files are automatically ignored by `.gitignore` and should **NEVER** be committed:

### Terraform Files
- `*.tfvars` (except `.tfvars.example`)
- `*.tfstate` and `*.tfstate.*`
- `.terraform/` directory
- `terraform.tfplan`

### Database Files
- `*.db`, `*.sqlite`, `*.sqlite3`
- `database/` directory contents

### Secret Files
- `secrets.yaml` (use `secrets.yaml.template` instead)
- Any file containing `*secret*`, `*password*`, `*key*`
- Environment files: `.env`, `.env.*`
- Certificate files: `*.pem`, `*.p12`, `*.pfx`

### Application Files
- `logs/` directory
- `uploads/` directory
- `instance/` directory
- `__pycache__/`, `*.pyc`

## 🔐 Secret Management

### Kubernetes Secrets

1. **Use Templates**: 
   - Template files (e.g., `secrets.yaml.template`) are committed
   - Actual secret files (e.g., `secrets.yaml`) are ignored

2. **Generate Secrets**:
   ```bash
   # Run the setup script
   ./scripts/setup-secrets.sh
   
   # Or manually copy and edit
   cp k8s/secrets.yaml.template k8s/secrets.yaml
   # Edit k8s/secrets.yaml with real values
   ```

3. **Deploy Secrets**:
   ```bash
   kubectl apply -f k8s/secrets.yaml
   ```

### Environment Variables

For local development, create `.env` file (ignored by Git):
```bash
FLASK_ENV=development
SECRET_KEY=your-dev-secret-key
DATABASE_URL=sqlite:///kubeopt.db
```

### GitHub Actions Secrets

Repository secrets are configured in GitHub:
- `AZURE_CREDENTIALS`: Service principal credentials for Azure deployment

## 🛡️ Security Features

### Application Security
- **Non-root containers**: All containers run as unprivileged users
- **Read-only root filesystem**: Where possible
- **Security contexts**: Proper user/group settings
- **Resource limits**: Prevents resource exhaustion attacks

### Network Security
- **Network policies**: Restricts pod-to-pod communication
- **TLS encryption**: All external traffic encrypted
- **Private container registry**: ACR with authentication

### Infrastructure Security
- **Azure AD integration**: Role-based access control
- **Service principal**: Limited scope permissions
- **Spot instances**: Cost optimization without security compromise

## 🔍 Security Monitoring

### Health Checks
- **Liveness probes**: Ensures container health
- **Readiness probes**: Traffic routing control
- **Startup probes**: Handles slow-starting containers

### Logging and Monitoring
- **Azure Monitor**: Centralized logging
- **Application logs**: Structured logging
- **Audit logs**: Kubernetes API access

### Metrics Collection
- **Prometheus integration**: Application metrics
- **Azure Insights**: Infrastructure metrics
- **Cost monitoring**: Azure Cost Management

## 🚨 Incident Response

### If Secrets are Accidentally Committed

1. **Immediate Actions**:
   ```bash
   # Remove from latest commit
   git reset --soft HEAD~1
   git reset HEAD <sensitive-file>
   git commit -m "Remove sensitive data"
   
   # Force push (if safe)
   git push --force-with-lease
   ```

2. **Rotate Compromised Secrets**:
   - Change all passwords/keys that were exposed
   - Update Kubernetes secrets
   - Redeploy applications

3. **Update Security**:
   - Review and update `.gitignore`
   - Add pre-commit hooks if needed
   - Train team on security practices

### Emergency Contacts
- **Azure Support**: For infrastructure issues
- **Security Team**: For security incidents
- **DevOps Lead**: For deployment issues

## 📋 Security Checklist

### Before Deployment
- [ ] All secrets in `secrets.yaml` are base64 encoded
- [ ] No sensitive data in Git history
- [ ] Azure service principal has minimal required permissions
- [ ] Resource limits are configured
- [ ] Health checks are working

### Monthly Security Review
- [ ] Rotate service principal credentials
- [ ] Review Azure AD access
- [ ] Update container images
- [ ] Check for security updates
- [ ] Verify backup integrity

### Security Best Practices
- [ ] Use strong, unique passwords
- [ ] Enable MFA for all accounts
- [ ] Regularly update dependencies
- [ ] Monitor security logs
- [ ] Test disaster recovery procedures

## 🔗 Security Resources

- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Git Security](https://docs.github.com/en/code-security)

## 📞 Reporting Security Issues

If you discover a security vulnerability:

1. **Do NOT** create a public issue
2. Send details to: security@kubeopt.com
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if known)

We will respond within 24 hours and work to resolve the issue promptly.

---

**Remember**: Security is everyone's responsibility! 🛡️