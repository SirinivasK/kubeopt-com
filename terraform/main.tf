# kubeopt.com - Azure AKS Terraform Configuration
# This configuration deploys the kubeopt-com website to Azure AKS
# Author: Srinivas Kondepudi - Nivaya Technologies

# Terraform configuration moved to versions.tf and backend.tf

# Configure the Azure Provider
provider "azurerm" {
  # Explicitly set subscription to prevent cross-org resource creation
  subscription_id = var.subscription_id
  
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data source for client configuration
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "kubeopt" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
}

# Container Registry for storing kubeopt-com image
resource "azurerm_container_registry" "kubeopt" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.kubeopt.name
  location            = azurerm_resource_group.kubeopt.location
  sku                 = "Basic"  # Cheapest option for startups
  admin_enabled       = true

  tags = var.common_tags
}

# Log Analytics Workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "kubeopt" {
  name                = "${var.cluster_name}-logs"
  location            = azurerm_resource_group.kubeopt.location
  resource_group_name = azurerm_resource_group.kubeopt.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.common_tags
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "kubeopt" {
  name                = var.cluster_name
  location            = azurerm_resource_group.kubeopt.location
  resource_group_name = azurerm_resource_group.kubeopt.name
  dns_prefix          = "${var.cluster_name}-dns"
  # kubernetes_version omitted to use AKS default for standard tier
  
  # Prevent accidental cluster deletion
  # lifecycle {
  #   prevent_destroy = true
  # }

  default_node_pool {
    name                 = "default"
    node_count           = var.node_count
    vm_size              = var.node_vm_size
    type                 = "VirtualMachineScaleSets"
    auto_scaling_enabled = true
    min_count            = var.min_node_count
    max_count            = var.max_node_count
    os_disk_size_gb      = var.disk_size_gb
    os_disk_type         = "Managed"  # Required for B-series VMs

    node_labels = {
      "kubeopt.com/node-type" = "website"
    }

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable Azure AD integration
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
  }

  # Network configuration
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  # Enable monitoring
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.kubeopt.id
  }

  # Aggressive auto-scaler profile for maximum cost optimization
  auto_scaler_profile {
    balance_similar_node_groups      = false
    expander                        = "least-waste"  # Choose nodes more cost-efficiently
    max_graceful_termination_sec    = "300"          # Faster termination for cost savings
    max_node_provisioning_time      = "10m"         # Faster provisioning
    max_unready_nodes              = 1              # Keep unready nodes low
    max_unready_percentage         = 10             # More aggressive scaling down
    new_pod_scale_up_delay         = "5s"           # React faster to scale up needs
    scale_down_delay_after_add     = "5m"           # Scale down faster after adding nodes
    scale_down_delay_after_delete  = "5s"           # Quick scale down
    scale_down_delay_after_failure = "1m"           # Quick recovery from failures
    scan_interval                  = "5s"           # More frequent scanning for efficiency
    scale_down_utilization_threshold = "0.3"        # More aggressive scale-down threshold
    empty_bulk_delete_max          = "3"            # Smaller bulk deletions
    skip_nodes_with_local_storage  = true
    skip_nodes_with_system_pods    = true
  }

  tags = var.common_tags
}

# Spot instance node pool for maximum cost savings
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  count                 = var.enable_spot_instances ? 1 : 0
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubeopt.id
  vm_size               = "Standard_B2s"  # Cheapest burstable VM
  auto_scaling_enabled  = true
  min_count             = 0
  max_count             = 3
  os_disk_size_gb       = var.disk_size_gb
  os_disk_type          = "Managed"  # Required for B-series VMs
  
  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = 0.05  # Maximum $0.05/hour (~$36/month max)
  
  node_labels = {
    "kubeopt.com/node-type" = "spot-workload"
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }
  
  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  tags = var.common_tags
}

# Role assignment for AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.kubeopt.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.kubeopt.id
  skip_service_principal_aad_check = true
}

# Role assignment for GitHub Actions service principal to manage AKS cluster
resource "azurerm_role_assignment" "github_actions_aks_admin" {
  count                = var.github_actions_service_principal_id != "" ? 1 : 0
  principal_id         = var.github_actions_service_principal_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.kubeopt.id
}

# Public IP for Load Balancer (for kubeopt.com domain)
resource "azurerm_public_ip" "kubeopt" {
  name                = "${var.cluster_name}-public-ip"
  resource_group_name = azurerm_kubernetes_cluster.kubeopt.node_resource_group
  location            = azurerm_resource_group.kubeopt.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.dns_label

  tags = merge(var.common_tags, {
    "service" = "kubeopt-website"
  })
}

# Configure Kubernetes provider (temporarily disabled for import)
# provider "kubernetes" {
#   host                   = azurerm_kubernetes_cluster.kubeopt.kube_config.0.host
#   client_certificate     = base64decode(azurerm_kubernetes_cluster.kubeopt.kube_config.0.client_certificate)
#   client_key             = base64decode(azurerm_kubernetes_cluster.kubeopt.kube_config.0.client_key)
#   cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubeopt.kube_config.0.cluster_ca_certificate)
# }

# Configure Helm provider (temporarily disabled for import)
# provider "helm" {
#   kubernetes {
#     host                   = azurerm_kubernetes_cluster.kubeopt.kube_config.0.host
#     client_certificate     = base64decode(azurerm_kubernetes_cluster.kubeopt.kube_config.0.client_certificate)
#     client_key             = base64decode(azurerm_kubernetes_cluster.kubeopt.kube_config.0.client_key)
#     cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubeopt.kube_config.0.cluster_ca_certificate)
#   }
# }

# Create namespace for kubeopt-com website (temporarily disabled for import)
# resource "kubernetes_namespace" "kubeopt" {
#   metadata {
#     name = "kubeopt-com"
#     labels = {
#       "app.kubernetes.io/name"    = "kubeopt-com"
#       "app.kubernetes.io/part-of" = "kubeopt-platform"
#     }
#   }
# }

# Install NGINX Ingress Controller (temporarily disabled for import)
# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "ingress-nginx"
#   version    = "4.7.1"
# 
#   create_namespace = true
# 
#   set {
#     name  = "controller.service.type"
#     value = "LoadBalancer"
#   }
# 
#   set {
#     name  = "controller.service.loadBalancerIP"
#     value = azurerm_public_ip.kubeopt.ip_address
#   }
# 
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
#     value = azurerm_kubernetes_cluster.kubeopt.node_resource_group
#   }
# 
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-pip-name"
#     value = azurerm_public_ip.kubeopt.name
#   }
# 
#   set {
#     name  = "controller.replicaCount"
#     value = "2"
#   }
# 
#   set {
#     name  = "controller.nodeSelector.beta\\.kubernetes\\.io/os"
#     value = "linux"
#   }
# 
#   set {
#     name  = "defaultBackend.nodeSelector.beta\\.kubernetes\\.io/os"
#     value = "linux"
#   }
# 
#   depends_on = [azurerm_kubernetes_cluster.kubeopt]
# }

# Install cert-manager for TLS certificates (temporarily disabled for import)
# resource "helm_release" "cert_manager" {
#   name       = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   namespace  = "cert-manager"
#   version    = "v1.12.0"
# 
#   create_namespace = true
# 
#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
# 
#   set {
#     name  = "nodeSelector.beta\\.kubernetes\\.io/os"
#     value = "linux"
#   }
# 
#   depends_on = [azurerm_kubernetes_cluster.kubeopt]
# }

# Azure Monitor for containers (additional monitoring)
resource "azurerm_monitor_diagnostic_setting" "kubeopt" {
  name               = "${var.cluster_name}-diag"
  target_resource_id = azurerm_kubernetes_cluster.kubeopt.id

  log_analytics_workspace_id = azurerm_log_analytics_workspace.kubeopt.id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Budget and cost alerts for cost monitoring
resource "azurerm_consumption_budget_resource_group" "kubeopt_budget" {
  name              = "kubeopt-monthly-budget"
  resource_group_id = azurerm_resource_group.kubeopt.id

  amount     = 50  # $50 monthly budget
  time_grain = "Monthly"

  time_period {
    start_date = "2026-01-01T00:00:00Z"
    end_date   = "2027-12-31T23:59:59Z"
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    
    contact_emails = [var.contact_email]
  }

  notification {
    enabled        = true
    threshold      = 90
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    
    contact_emails = [var.contact_email]
  }
}