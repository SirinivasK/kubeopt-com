# Outputs for kubeopt.com Azure AKS Deployment

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.kubeopt.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.kubeopt.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.kubeopt.id
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.kubeopt.fqdn
}

output "aks_cluster_kube_config" {
  description = "Kube config for the AKS cluster"
  value       = azurerm_kubernetes_cluster.kubeopt.kube_config_raw
  sensitive   = true
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.kubeopt.name
}

output "acr_login_server" {
  description = "Login server for the Azure Container Registry"
  value       = azurerm_container_registry.kubeopt.login_server
}

output "acr_admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = azurerm_container_registry.kubeopt.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password for the Azure Container Registry"
  value       = azurerm_container_registry.kubeopt.admin_password
  sensitive   = true
}

output "public_ip_address" {
  description = "Public IP address for the load balancer"
  value       = azurerm_public_ip.kubeopt.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN for the public IP"
  value       = azurerm_public_ip.kubeopt.fqdn
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.kubeopt.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.kubeopt.name
}

output "nginx_ingress_ip" {
  description = "IP address of the NGINX ingress controller"
  value       = azurerm_public_ip.kubeopt.ip_address
}

output "domain_configuration" {
  description = "Domain configuration instructions"
  value = {
    domain     = var.domain_name
    ip_address = azurerm_public_ip.kubeopt.ip_address
    dns_records = [
      {
        type  = "A"
        name  = "@"
        value = azurerm_public_ip.kubeopt.ip_address
        ttl   = 300
      },
      {
        type  = "CNAME"
        name  = "www"
        value = var.domain_name
        ttl   = 300
      }
    ]
    instructions = "Add these DNS records to your GoDaddy domain configuration"
  }
}

output "kubectl_commands" {
  description = "Useful kubectl commands for managing the deployment"
  value = {
    get_credentials = "az aks get-credentials --resource-group ${azurerm_resource_group.kubeopt.name} --name ${azurerm_kubernetes_cluster.kubeopt.name}"
    get_pods        = "kubectl get pods -n kubeopt-com"
    get_services    = "kubectl get services -n kubeopt-com"
    get_ingress     = "kubectl get ingress -n kubeopt-com"
    logs            = "kubectl logs -n kubeopt-com deployment/kubeopt-website"
    port_forward    = "kubectl port-forward -n kubeopt-com service/kubeopt-website 8080:80"
  }
}

output "deployment_urls" {
  description = "URLs for accessing the deployed website"
  value = {
    public_ip_url = "http://${azurerm_public_ip.kubeopt.ip_address}"
    domain_url    = "https://${var.domain_name}"
    temp_url      = "http://${azurerm_public_ip.kubeopt.fqdn}"
  }
}

output "monitoring_urls" {
  description = "URLs for monitoring and management"
  value = {
    azure_portal_aks = "https://portal.azure.com/#@/resource${azurerm_kubernetes_cluster.kubeopt.id}"
    azure_portal_acr = "https://portal.azure.com/#@/resource${azurerm_container_registry.kubeopt.id}"
    log_analytics    = "https://portal.azure.com/#@/resource${azurerm_log_analytics_workspace.kubeopt.id}"
  }
}

output "next_steps" {
  description = "Next steps after Terraform deployment"
  value = [
    "1. Configure GoDaddy DNS records using the domain_configuration output",
    "2. Build and push your Docker image to ACR: docker build -t ${azurerm_container_registry.kubeopt.login_server}/kubeopt-com:latest .",
    "3. Push the image: docker push ${azurerm_container_registry.kubeopt.login_server}/kubeopt-com:latest",
    "4. Deploy Kubernetes manifests: kubectl apply -f k8s/",
    "5. Verify deployment: kubectl get pods -n kubeopt-com",
    "6. Check ingress: kubectl get ingress -n kubeopt-com",
    "7. Monitor logs: kubectl logs -n kubeopt-com deployment/kubeopt-website",
    "8. Access website at: https://${var.domain_name}"
  ]
}

output "cost_optimization_tips" {
  description = "Cost optimization recommendations"
  value = [
    "✅ Using spot instances for cost savings",
    "✅ Auto-scaling enabled (min: ${var.min_node_count}, max: ${var.max_node_count})",
    "✅ Right-sized VMs: ${var.node_vm_size}",
    "✅ Log retention set to ${var.log_retention_days} days",
    "💡 Monitor resource usage and adjust VM sizes as needed",
    "💡 Consider using Azure Reserved Instances for long-term savings",
    "💡 Review and adjust auto-scaling parameters based on traffic patterns"
  ]
}

# DNS Zone Outputs
output "dns_zone_name_servers" {
  description = "Name servers for the DNS zone"
  value       = var.enable_azure_dns ? azurerm_dns_zone.kubeopt[0].name_servers : []
}

output "dns_zone_id" {
  description = "ID of the DNS zone"
  value       = var.enable_azure_dns ? azurerm_dns_zone.kubeopt[0].id : null
}

output "dns_configuration_instructions" {
  description = "Instructions for configuring DNS"
  value = var.enable_azure_dns ? {
    step_1       = "🔄 Update name servers in GoDaddy to:"
    name_servers = azurerm_dns_zone.kubeopt[0].name_servers
    step_2       = "⏰ Wait 24-48 hours for DNS propagation"
    step_3       = "✅ Verify DNS with: nslookup kubeopt.com"
    step_4       = "🌐 Access website at: https://kubeopt.com"
    manual_config = ""
    } : {
    step_1       = ""
    name_servers = []
    step_2       = ""
    step_3       = ""
    step_4       = ""
    manual_config = "Configure DNS manually in GoDaddy using the domain_configuration output"
  }
}