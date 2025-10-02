# GoDaddy DNS Configuration for kubeopt.com

This guide explains how to configure your GoDaddy domain (kubeopt.com) to point to your Azure AKS deployment.

## Prerequisites

- Domain purchased from GoDaddy: `kubeopt.com`
- Azure AKS infrastructure deployed via Terraform
- Static IP address from Azure deployment

## Step 1: Get Your Azure Static IP Address

After running Terraform, get your static IP address:

```bash
# From Terraform outputs
terraform output public_ip_address

# Or from Azure CLI
az network public-ip show \
  --resource-group MC_rg-kubeopt-com_aks-kubeopt-com_eastus \
  --name aks-kubeopt-com-public-ip \
  --query ipAddress -o tsv
```

Expected output: `20.X.X.X` (your actual IP will be different)

## Step 2: Access GoDaddy DNS Management

1. Log in to your GoDaddy account at https://account.godaddy.com/
2. Go to **My Products** → **All Products and Services**
3. Find your `kubeopt.com` domain
4. Click **DNS** button next to your domain

## Step 3: Configure DNS Records

### Delete Default Records (if present)
Remove any existing A records that point to parking pages:
- Delete default A record for `@` (root domain)
- Delete default CNAME record for `www`

### Add Required DNS Records

Add the following DNS records:

#### 1. Root Domain (A Record)
- **Type**: A
- **Name**: `@` (or leave blank)
- **Value**: `YOUR_AZURE_STATIC_IP` (e.g., `20.X.X.X`)
- **TTL**: 600 seconds

#### 2. WWW Subdomain (CNAME Record)
- **Type**: CNAME
- **Name**: `www`
- **Value**: `kubeopt.com` (points to root domain)
- **TTL**: 600 seconds

#### 3. Optional: Wildcard Subdomain (if needed)
- **Type**: A
- **Name**: `*`
- **Value**: `YOUR_AZURE_STATIC_IP`
- **TTL**: 600 seconds

## Step 4: Verify DNS Configuration

### Using DNS Lookup Tools

1. **Online DNS Checker**: https://dnschecker.org/
   - Enter `kubeopt.com`
   - Check A record propagation globally

2. **Command Line Verification**:
   ```bash
   # Check A record
   nslookup kubeopt.com
   
   # Check CNAME record
   nslookup www.kubeopt.com
   
   # Using dig (more detailed)
   dig kubeopt.com A
   dig www.kubeopt.com CNAME
   ```

### Expected Results
```bash
# kubeopt.com A record
kubeopt.com.           300     IN      A       20.X.X.X

# www.kubeopt.com CNAME record
www.kubeopt.com.       300     IN      CNAME   kubeopt.com.
```

## Step 5: SSL Certificate Configuration

Your AKS deployment uses cert-manager with Let's Encrypt for automatic SSL certificates.

### Verify Certificate Status
```bash
# Check certificate status
kubectl get certificates -n kubeopt-com

# Check certificate details
kubectl describe certificate kubeopt-com-tls -n kubeopt-com

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

### Troubleshooting SSL Issues

If SSL certificates don't auto-generate:

1. **Check DNS propagation** (wait 24-48 hours for full propagation)
2. **Verify ingress configuration**:
   ```bash
   kubectl get ingress -n kubeopt-com
   kubectl describe ingress kubeopt-website-ingress -n kubeopt-com
   ```
3. **Check Let's Encrypt rate limits**: https://letsencrypt.org/docs/rate-limits/

## Step 6: Test Your Website

After DNS propagation (5-30 minutes for basic propagation, up to 48 hours for global):

```bash
# Test HTTP access (should redirect to HTTPS)
curl -I http://kubeopt.com

# Test HTTPS access
curl -I https://kubeopt.com

# Test WWW subdomain
curl -I https://www.kubeopt.com
```

### Browser Testing
1. Open https://kubeopt.com in your browser
2. Verify SSL certificate is valid (green lock icon)
3. Test https://www.kubeopt.com redirects properly
4. Check all website pages load correctly

## DNS Record Summary

| Type  | Name | Value                    | TTL | Purpose                     |
|-------|------|--------------------------|-----|-----------------------------|
| A     | @    | YOUR_AZURE_STATIC_IP     | 600 | Root domain                 |
| CNAME | www  | kubeopt.com             | 600 | WWW subdomain               |
| A     | *    | YOUR_AZURE_STATIC_IP     | 600 | Wildcard (optional)         |

## Troubleshooting Common Issues

### 1. DNS Not Propagating
- **Symptom**: Domain still shows parking page or doesn't resolve
- **Solution**: Wait 24-48 hours for full global propagation
- **Check**: Use different DNS checkers and locations

### 2. SSL Certificate Issues
- **Symptom**: "Certificate not secure" warnings
- **Solution**: 
  ```bash
  # Delete and recreate certificate
  kubectl delete certificate kubeopt-com-tls -n kubeopt-com
  kubectl apply -f k8s/ingress.yaml
  ```

### 3. 404 Errors
- **Symptom**: DNS resolves but shows 404 errors
- **Solution**: Check ingress and service configuration
  ```bash
  kubectl get services -n kubeopt-com
  kubectl get pods -n kubeopt-com
  kubectl logs -n kubeopt-com deployment/kubeopt-website
  ```

### 4. Redirect Loops
- **Symptom**: Browser shows "too many redirects"
- **Solution**: Check ingress SSL redirect configuration

## Advanced Configuration

### Email Subdomains (Optional)
If you plan to use email with your domain:
- **Type**: MX
- **Name**: `@`
- **Value**: Your email provider's MX records
- **Priority**: As specified by email provider

### API Subdomain (Future)
For API endpoints:
- **Type**: CNAME
- **Name**: `api`
- **Value**: `kubeopt.com`
- **TTL**: 600

## Monitoring and Maintenance

### Regular Checks
1. **Monthly**: Verify SSL certificate renewal
2. **Quarterly**: Check DNS record accuracy
3. **Annually**: Review domain registration renewal

### Automation
Consider setting up monitoring for:
- SSL certificate expiration
- DNS record changes
- Website availability

## Security Considerations

1. **Enable Domain Lock**: In GoDaddy settings to prevent unauthorized transfers
2. **Two-Factor Authentication**: Enable 2FA on your GoDaddy account
3. **DNS Security**: Consider using Cloudflare for additional DDoS protection
4. **Regular Backups**: Keep backups of your DNS configuration

## Support Contacts

- **GoDaddy Support**: https://www.godaddy.com/help
- **Azure Support**: https://azure.microsoft.com/en-us/support/
- **Let's Encrypt Community**: https://community.letsencrypt.org/

---

**Note**: DNS propagation can take up to 48 hours globally. Be patient and use multiple DNS checking tools to verify propagation status.