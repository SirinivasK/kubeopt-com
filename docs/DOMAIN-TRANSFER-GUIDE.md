# Domain Transfer Guide: GoDaddy to Azure

Complete guide for transferring your kubeopt.com domain from GoDaddy to Azure for unified management.

## Transfer Options Comparison

| Option | Registration | DNS Management | Cost | Complexity | Recommended |
|--------|-------------|----------------|------|------------|------------|
| **Azure App Service Domains** | Azure | Azure | ~$12/year | Low | ✅ **Yes** |
| **GoDaddy + Azure DNS** | GoDaddy | Azure | ~$15/year | Medium | ⭐ Alternative |
| **Keep GoDaddy** | GoDaddy | GoDaddy | ~$15/year | Low | ❌ No |

## Option 1: Full Transfer to Azure (Recommended)

### Benefits
- ✅ **Unified Management**: Everything in Azure Portal
- ✅ **Better Integration**: Seamless with Azure services
- ✅ **Auto-renewal**: Never worry about domain expiration
- ✅ **Cost Effective**: Competitive pricing
- ✅ **Advanced DNS**: More features than GoDaddy

### Steps for Full Transfer

#### Step 1: Prepare Domain in GoDaddy
```bash
# 1. Login to GoDaddy account
# 2. Go to Domain Manager → kubeopt.com
# 3. Unlock domain (Domain Settings → Lock → OFF)
# 4. Disable privacy protection temporarily
# 5. Get authorization code (Transfer → Transfer to another registrar)
```

#### Step 2: Initiate Transfer in Azure
```bash
# Option A: Azure Portal
# 1. Go to Azure Portal → App Service Domains
# 2. Click "+ Create" → "Transfer domain"
# 3. Enter kubeopt.com
# 4. Enter authorization code from GoDaddy
# 5. Complete payment (~$12)

# Option B: Azure CLI
az appservice domain create \
  --resource-group rg-kubeopt-com \
  --name kubeopt.com \
  --contact-info @domain-contact.json \
  --privacy-protection-enabled false \
  --auto-renew true
```

#### Step 3: Create Domain Contact File
```json
# Save as domain-contact.json
{
  "addressMailing": {
    "address1": "Your Address",
    "city": "Your City", 
    "country": "US",
    "postalCode": "12345",
    "state": "Your State"
  },
  "email": "admin@kubeopt.com",
  "nameFirst": "Your Name",
  "nameLast": "Your Last Name",
  "phone": "+1.1234567890"
}
```

#### Step 4: Verify Transfer
```bash
# Check transfer status
az appservice domain show \
  --resource-group rg-kubeopt-com \
  --name kubeopt.com

# Should show: "registrationStatus": "Active"
```

#### Step 5: Configure DNS Automatically
```bash
# Azure will automatically create DNS zone
# Your Terraform configuration will handle DNS records
terraform apply
```

## Option 2: Keep GoDaddy + Azure DNS

### Benefits
- ✅ **Keep Registration**: No transfer needed
- ✅ **Better DNS**: Azure DNS features
- ✅ **Quick Setup**: Immediate implementation
- ✅ **Reversible**: Easy to change back

### Steps for DNS-Only Migration

#### Step 1: Deploy Terraform with Azure DNS
```bash
# Update terraform.tfvars
enable_azure_dns = true

# Deploy infrastructure
terraform apply

# Get Azure name servers
terraform output dns_zone_name_servers
```

#### Step 2: Update GoDaddy Name Servers
```bash
# 1. Login to GoDaddy
# 2. Go to DNS Management for kubeopt.com
# 3. Change Name Servers to Custom:
#    - ns1-xx.azure-dns.com
#    - ns2-xx.azure-dns.net  
#    - ns3-xx.azure-dns.org
#    - ns4-xx.azure-dns.info
# 4. Save changes
```

#### Step 3: Verify DNS Propagation
```bash
# Check name servers
dig NS kubeopt.com

# Check A record
dig A kubeopt.com

# Should show Azure DNS servers and your AKS IP
```

## Updated Terraform Configuration

Your Terraform now includes Azure DNS management. To enable it:

### 1. Update Variables
```bash
# In terraform.tfvars
enable_azure_dns = true
enable_api_subdomain = false  # Set to true if you want api.kubeopt.com
enable_staging_subdomain = false  # Set to true if you want staging.kubeopt.com

# Optional: Add email MX records
mx_records = [
  {
    preference = 10
    exchange = "mail.your-email-provider.com"
  }
]
```

### 2. Deploy Updated Infrastructure
```bash
cd terraform/
terraform plan  # Review DNS changes
terraform apply # Apply changes
```

### 3. Get Name Servers
```bash
# Get the name servers to update in GoDaddy
terraform output dns_configuration_instructions
```

## Cost Comparison

### Azure App Service Domains
- **Registration**: ~$12/year
- **DNS**: Included
- **SSL**: Free (Let's Encrypt)
- **Total**: ~$12/year

### GoDaddy + Azure DNS
- **Registration**: ~$15/year (GoDaddy)
- **DNS**: ~$0.50/month (~$6/year)
- **SSL**: Free (Let's Encrypt)
- **Total**: ~$21/year

### GoDaddy Only
- **Registration**: ~$15/year
- **DNS**: Included
- **SSL**: Free (Let's Encrypt)
- **Total**: ~$15/year

## Migration Timeline

### Option 1: Full Transfer (5-7 days)
```
Day 1: Initiate transfer in Azure
Day 2-5: Transfer processing
Day 5-7: DNS propagation complete
```

### Option 2: DNS Only (1-2 days)
```
Day 1: Deploy Azure DNS, update GoDaddy name servers
Day 1-2: DNS propagation complete
```

## Terraform Commands for Different Scenarios

### Scenario A: New Deployment with Azure DNS
```bash
# Enable Azure DNS from the start
terraform apply -var="enable_azure_dns=true"
```

### Scenario B: Migrate Existing Deployment to Azure DNS
```bash
# Add DNS zone to existing infrastructure
terraform apply -var="enable_azure_dns=true"

# Output will show name servers to update in GoDaddy
terraform output dns_configuration_instructions
```

### Scenario C: Rollback to GoDaddy DNS
```bash
# Disable Azure DNS
terraform apply -var="enable_azure_dns=false"

# Update GoDaddy to use GoDaddy name servers
# Configure A and CNAME records manually in GoDaddy
```

## Advanced DNS Features with Azure

### 1. Traffic Manager (Global Load Balancing)
```hcl
# Add to terraform/dns.tf
resource "azurerm_traffic_manager_profile" "kubeopt" {
  name                = "kubeopt-traffic-manager"
  resource_group_name = azurerm_resource_group.kubeopt.name

  traffic_routing_method = "Geographic"
  
  dns_config {
    relative_name = "kubeopt"
    ttl          = 300
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/health"
  }
}
```

### 2. Private DNS Zones
```hcl
# For internal services
resource "azurerm_private_dns_zone" "internal" {
  name                = "internal.kubeopt.com"
  resource_group_name = azurerm_resource_group.kubeopt.name
}
```

### 3. DNS Alias Records
```hcl
# Point directly to Azure resources
resource "azurerm_dns_a_record" "direct" {
  name                = "direct"
  zone_name           = azurerm_dns_zone.kubeopt.name
  resource_group_name = azurerm_resource_group.kubeopt.name
  ttl                 = 300
  
  target_resource_id = azurerm_public_ip.kubeopt.id
}
```

## Monitoring and Alerts

### DNS Query Monitoring
```bash
# Enable DNS analytics
az monitor diagnostic-settings create \
  --name dns-analytics \
  --resource $(terraform output dns_zone_id) \
  --logs '[{"category":"QueryLogs","enabled":true}]' \
  --workspace $(terraform output log_analytics_workspace_id)
```

### DNS Health Checks
```bash
# Set up availability tests
az monitor app-insights web-test create \
  --resource-group rg-kubeopt-com \
  --name kubeopt-dns-test \
  --location "West Europe" \
  --kind ping \
  --web-test-name kubeopt-availability \
  --url https://kubeopt.com/health
```

## Troubleshooting

### Common Issues

#### 1. Transfer Stuck/Failed
```bash
# Check transfer status
az appservice domain show \
  --resource-group rg-kubeopt-com \
  --name kubeopt.com \
  --query "registrationStatus"

# Contact Azure support if stuck > 7 days
```

#### 2. DNS Not Propagating
```bash
# Check Azure DNS
nslookup kubeopt.com ns1-xx.azure-dns.com

# Check global propagation
dig @8.8.8.8 kubeopt.com A
dig @1.1.1.1 kubeopt.com A
```

#### 3. SSL Certificate Issues After Transfer
```bash
# Delete and recreate certificates
kubectl delete certificate kubeopt-com-tls -n kubeopt-com
kubectl apply -f k8s/ingress.yaml

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

## Rollback Plan

If you need to rollback:

### From Azure DNS to GoDaddy DNS
```bash
# 1. Get your current IP
kubectl get ingress -n kubeopt-com

# 2. In GoDaddy, change name servers back to GoDaddy's
# 3. Manually configure A and CNAME records
# 4. Disable Azure DNS in Terraform
terraform apply -var="enable_azure_dns=false"
```

### From Azure Domains back to GoDaddy
```bash
# This requires a domain transfer back (60-day wait period)
# Generally not recommended unless absolutely necessary
```

## Recommendations

### For kubeopt.com specifically:

1. **Start with Option 2** (GoDaddy + Azure DNS):
   - Quick implementation
   - Test Azure DNS features
   - Easy rollback if needed

2. **Migrate to Option 1** later (Full Azure):
   - After confirming everything works
   - During next renewal period
   - For long-term cost savings

3. **Timeline**:
   ```
   Week 1: Deploy with GoDaddy + Azure DNS
   Week 2-4: Test and monitor
   Month 3-6: Transfer registration to Azure (optional)
   ```

## Next Steps

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"content": "Examine current kubeopt-com website structure and code", "status": "completed"}, {"content": "Analyze aks-cost-optimizer tool for alignment requirements", "status": "completed"}, {"content": "Complete missing website functionality and alignment", "status": "completed"}, {"content": "Create Terraform configuration for Azure AKS deployment", "status": "completed"}, {"content": "Create Kubernetes manifests for website deployment", "status": "completed"}, {"content": "Set up GitHub Actions for CI/CD pipeline", "status": "completed"}, {"content": "Configure domain routing for kubeopt.com", "status": "completed"}, {"content": "Test and verify complete deployment", "status": "completed"}]