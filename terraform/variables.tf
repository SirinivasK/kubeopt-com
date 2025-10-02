# Variables for kubeopt.com Azure AKS Deployment

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-kubeopt-com"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-kubeopt-com"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "acrkubeoptio"
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.acr_name))
    error_message = "ACR name must only contain alphanumeric characters."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = null  # Use AKS default version for standard tier
}

variable "node_count" {
  description = "Initial number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum number of nodes for auto-scaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for auto-scaling"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "dns_label" {
  description = "DNS label for the public IP"
  type        = string
  default     = "kubeopt-com"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "kubeopt.com"
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs for AKS admin access"
  type        = list(string)
  default     = []
}

# Add subscription_id variable for security
variable "subscription_id" {
  description = "Azure subscription ID to prevent cross-org resource creation"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "Subscription ID must be a valid GUID format."
  }
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "kubeopt-com"
    Owner       = "nivaya-technologies"
    ManagedBy   = "terraform"
    Purpose     = "website-hosting"
  }
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy for AKS"
  type        = bool
  default     = false
}

variable "enable_http_application_routing" {
  description = "Enable HTTP application routing"
  type        = bool
  default     = false
}

variable "network_plugin" {
  description = "Network plugin for AKS (azure or kubenet)"
  type        = string
  default     = "azure"
  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either 'azure' or 'kubenet'."
  }
}

variable "network_policy" {
  description = "Network policy for AKS (azure, calico, or null)"
  type        = string
  default     = "azure"
  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be either 'azure' or 'calico'."
  }
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "ssl_certificate_issuer" {
  description = "SSL certificate issuer (letsencrypt-staging or letsencrypt-prod)"
  type        = string
  default     = "letsencrypt-prod"
}

variable "contact_email" {
  description = "Contact email for SSL certificate notifications"
  type        = string
  default     = "admin@kubeopt.com"
}

variable "website_image_tag" {
  description = "Tag for the kubeopt-com website container image"
  type        = string
  default     = "latest"
}

variable "website_replicas" {
  description = "Number of website pod replicas"
  type        = number
  default     = 1
}

variable "website_cpu_request" {
  description = "CPU request for website pods"
  type        = string
  default     = "50m"
}

variable "website_memory_request" {
  description = "Memory request for website pods"
  type        = string
  default     = "64Mi"
}

variable "website_cpu_limit" {
  description = "CPU limit for website pods"
  type        = string
  default     = "200m"
}

variable "website_memory_limit" {
  description = "Memory limit for website pods"
  type        = string
  default     = "256Mi"
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor for containers"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "Enable cluster auto-scaling"
  type        = bool
  default     = true
}

variable "enable_spot_instances" {
  description = "Enable spot instance node pool for cost optimization"
  type        = bool
  default     = true
}

variable "disk_size_gb" {
  description = "Disk size in GB for AKS nodes"
  type        = number
  default     = 30
}

variable "max_pods" {
  description = "Maximum number of pods per node"
  type        = number
  default     = 30
}

# DNS Configuration Variables
variable "enable_azure_dns" {
  description = "Enable Azure DNS zone management"
  type        = bool
  default     = true
}

variable "enable_api_subdomain" {
  description = "Create API subdomain"
  type        = bool
  default     = false
}

variable "enable_staging_subdomain" {
  description = "Create staging subdomain"
  type        = bool
  default     = false
}

variable "txt_records" {
  description = "List of TXT records for domain verification"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "mx_records" {
  description = "List of MX records for email"
  type = list(object({
    preference = number
    exchange   = string
  }))
  default = []
}