# Azure DNS Zone Configuration for kubeopt.com
# This file manages DNS records in Azure DNS

# Create DNS Zone
resource "azurerm_dns_zone" "kubeopt" {
  count               = var.enable_azure_dns ? 1 : 0
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.kubeopt.name

  tags = var.common_tags
}

# A Record for root domain
resource "azurerm_dns_a_record" "root" {
  count               = var.enable_azure_dns ? 1 : 0
  name                = "@"
  zone_name           = azurerm_dns_zone.kubeopt[0].name
  resource_group_name = azurerm_resource_group.kubeopt.name
  ttl                 = 300
  records             = [azurerm_public_ip.kubeopt.ip_address]

  tags = var.common_tags
}

# CNAME Record for www subdomain
resource "azurerm_dns_cname_record" "www" {
  count               = var.enable_azure_dns ? 1 : 0
  name                = "www"
  zone_name           = azurerm_dns_zone.kubeopt[0].name
  resource_group_name = azurerm_resource_group.kubeopt.name
  ttl                 = 300
  record              = var.domain_name

  tags = var.common_tags
}

# Optional: API subdomain for future use
resource "azurerm_dns_cname_record" "api" {
  count               = var.enable_azure_dns && var.enable_api_subdomain ? 1 : 0
  name                = "api"
  zone_name           = azurerm_dns_zone.kubeopt[0].name
  resource_group_name = azurerm_resource_group.kubeopt.name
  ttl                 = 300
  record              = var.domain_name

  tags = var.common_tags
}

# Optional: Staging subdomain
resource "azurerm_dns_cname_record" "staging" {
  count               = var.enable_azure_dns && var.enable_staging_subdomain ? 1 : 0
  name                = "staging"
  zone_name           = azurerm_dns_zone.kubeopt[0].name
  resource_group_name = azurerm_resource_group.kubeopt.name
  ttl                 = 300
  record              = var.domain_name

  tags = var.common_tags
}

# TXT Record for domain verification (if needed for services)
resource "azurerm_dns_txt_record" "verification" {
  count               = var.enable_azure_dns ? length(var.txt_records) : 0
  name                = var.txt_records[count.index].name
  zone_name           = azurerm_dns_zone.kubeopt[0].name
  resource_group_name = azurerm_resource_group.kubeopt.name
  ttl                 = 300

  record {
    value = var.txt_records[count.index].value
  }

  tags = var.common_tags
}

# MX Records for email (if you plan to use email with the domain)
resource "azurerm_dns_mx_record" "email" {
  count               = var.enable_azure_dns && length(var.mx_records) > 0 ? 1 : 0
  name                = "@"
  zone_name           = azurerm_dns_zone.kubeopt[0].name
  resource_group_name = azurerm_resource_group.kubeopt.name
  ttl                 = 3600

  dynamic "record" {
    for_each = var.mx_records
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }

  tags = var.common_tags
}

# CAA Records for SSL certificate authority authorization
resource "azurerm_dns_caa_record" "ssl" {
  count               = var.enable_azure_dns ? 1 : 0
  name                = "@"
  zone_name           = azurerm_dns_zone.kubeopt[0].name
  resource_group_name = azurerm_resource_group.kubeopt.name
  ttl                 = 300

  record {
    flags = 0
    tag   = "issue"
    value = "letsencrypt.org"
  }

  record {
    flags = 0
    tag   = "iodef"
    value = "mailto:admin@kubeopt.com"
  }

  tags = var.common_tags
}