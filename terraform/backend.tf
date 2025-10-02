terraform {
  backend "azurerm" {
    # Storage account details - update these with your actual values
    resource_group_name  = "rg-kubeopt-terraform-state"
    storage_account_name = "stkubeopttfstate" # Replace with your actual storage account name
    container_name       = "tfstate"
    key                  = "kubeopt/prod/terraform.tfstate"
    subscription_id      = "aa6078c8-02d7-459d-a5cb-99da0f7752f2"

    # Authentication will be handled via Azure CLI or environment variables
    # use_azuread_auth = true  # Uncomment if using Azure AD authentication
  }
}