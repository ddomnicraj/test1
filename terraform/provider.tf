#terraform {
#    backend "azurerm" {}
#}

variable "subscription_id" { default = null }
variable "client_id" { default = null }
variable "client_secret" { default = null }
variable "tenant_id" { default = null }

# Configure the Microsoft Azure Provider
 provider "azurerm" {
  features {}
  skip_provider_registration = true
  subscription_id = ""
  tenant_id       = ""
  client_id       = ""
  client_secret   = ""
 }
