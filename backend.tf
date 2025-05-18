terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-hylastix"        
    storage_account_name = "tfhylastix"             
    container_name       = "terraform-state"                     
    key                  = "terraform-hylastix-infra/terraform.tfstate"  
  }
}
