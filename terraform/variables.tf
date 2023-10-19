variable resource_group_name {} #required input
variable region {}              #required input
variable environment {}         #required input

#Blocks

variable "tags" {
  type = map
}

variable log_analytics_workspace {
  description = "properties for Log Analytics workspace"
  type = object({
    name              = string
    sku               = string
    retention_in_days = number
  })
}

variable log_analytics_sol {
  description = "properties of Log Analytics workspace solution"
  type = object({
    name           = string
    plan_publisher = string
    plan_product   = string
  })
}

variable default_node_pool {
  type = object({
    name                  = string
    enable_auto_scaling   = bool
    enable_node_public_ip = bool
    max_count             = number
    max_pods              = number
    min_count             = number
    node_count            = number
    os_disk_size_gb       = number
    tags                  = map(string)
    type                  = string
    vm_size               = string
  })
}

variable network_profile {
  type = object({
    dns_service_ip     = string
    docker_bridge_cidr = string
    load_balancer_sku  = string
    network_plugin     = string
    service_cidr       = string
  })
}

variable kubernetes_cluster {
  type = object({
    name                   = string
    dns_prefix             = string
    kubernetes_version     = string
    rbac_enabled           = bool
    oms_agent_enabled      = bool
    kube_dashboard_enabled = bool
    azure_policy_enabled   = bool
  })
}

variable linux_profile {
  type = map
  default = {
    admin_username    = "azureuser"
    ssh_key_file_path = "id_rsa.pub"
  }
}

#Block specific individual variables

variable log_analytics_ws_name { default = null }
variable log_analytics_ws_sku { default = null } #PerGB2018
# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_ws_retention { default = 0 }

variable log_analytics_sol_name { default = null }
variable log_analytics_sol_publisher { default = null }
variable log_analytics_sol_product { default = null }

variable vnet_name { }
variable vnet_subnet_name { }

variable default_np_name { default = null }
variable default_np_zones { default = [] }
variable default_np_auto_scaling { default = false }
variable default_np_node_pip { default = false }
variable default_np_max_count { default = null }
variable default_np_max_pods { default = 30 }
variable default_np_min_count { default = null }
variable default_np_node_count { default = 2 }
variable default_np_node_labels { default = {} }
variable default_np_taints { default = [] }
variable default_np_os_disk_size_gb { default = 100 }
variable default_np_tags { default = {} }
variable default_np_type { default = null }
variable default_np_vm_size { default = null }

variable network_dns_service_ip { default = null }
variable network_docker_bridge_cidr { default = null }
variable network_lb_sku { default = null }
variable network_plugin { default = null }
variable network_service_cidr { default = null }

variable aks_version { default = "1.15.10" }
variable aks_rbac_enabled { default = true }
variable aks_oms_agent_enabled { default = false }
variable aks_kube_dashboard_enabled { default = false }
variable aks_azure_policy_enabled { default = false }

#standard maps
variable regions {
  type        = map
  description = "validated regions in Azure CSP"

  default = {
    eastus        = { name = "East US", prefix = "us5" }
    eastus2       = { name = "East US 2", prefix = "us6" }
    centralus     = { name = "Central US", prefix = "us7" }
	southcentralus = { name = "South Central US", prefix = "us9" }
    westus2       = { name = "West US 2", prefix = "us8" }
    northeurope   = { name = "North Europe", prefix = "ie1" }
    westeurope    = { name = "West Europe", prefix = "nl1" }
    southeastasia = { name = "Southeast Asia", prefix = "sg1" }
    eastasia      = { name = "East Asia", prefix = "hk1" }
  }
}
variable environments {
  type        = map
  description = "environment keys to reference in module"

  default = {
    sandbox     = "sbx"
    development = "dev"
    qa          = "qa"
    uat         = "uat"
    production  = "prod"
  }
}
