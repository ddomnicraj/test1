locals {
  region                     = lookup(var.regions, var.region)
  log_analytics_ws_name      = lookup(var.log_analytics_workspace, "name", null) == null ? var.log_analytics_ws_name : var.log_analytics_workspace.name
  log_analytics_ws_sku       = lookup(var.log_analytics_workspace, "sku", null) == null ? var.log_analytics_ws_sku : var.log_analytics_workspace.sku
  log_analytics_ws_retention = lookup(var.log_analytics_workspace, "retention_in_days", null) == null ? var.log_analytics_ws_retention : var.log_analytics_workspace.retention_in_days

  log_analytics_sol_name      = lookup(var.log_analytics_sol, "name", null) == null ? var.log_analytics_sol_name : var.log_analytics_sol.name
  log_analytics_sol_publisher = lookup(var.log_analytics_sol, "plan_publisher", null) == null ? var.log_analytics_sol_publisher : var.log_analytics_sol.plan_publisher
  log_analytics_sol_product   = lookup(var.log_analytics_sol, "plan_product", null) == null ? var.log_analytics_sol_product : var.log_analytics_sol.plan_product

  vnet_name        = var.vnet_name
  vnet_subnet_name = var.vnet_subnet_name

  default_np_name            = lookup(var.default_node_pool, "name", null) == null ? var.default_np_name : var.default_node_pool.name
  default_np_auto_scaling    = lookup(var.default_node_pool, "enable_auto_scaling", null) == null ? var.default_np_auto_scaling : var.default_node_pool.enable_auto_scaling
  default_np_node_pip        = lookup(var.default_node_pool, "enable_node_public_ip", null) == null ? var.default_np_node_pip : var.default_node_pool.enable_node_public_ip
  default_np_max_count       = lookup(var.default_node_pool, "max_count", null) == null ? var.default_np_max_count : var.default_node_pool.max_count
  default_np_max_pods        = lookup(var.default_node_pool, "max_pods", null) == null ? var.default_np_max_pods : var.default_node_pool.max_pods
  default_np_min_count       = lookup(var.default_node_pool, "min_count", null) == null ? var.default_np_min_count : var.default_node_pool.min_count
  default_np_node_count      = lookup(var.default_node_pool, "node_count", null) == null ? var.default_np_node_count : var.default_node_pool.node_count
  default_np_os_disk_size_gb = lookup(var.default_node_pool, "os_disk_size_gb", null) == null ? var.default_np_os_disk_size_gb : var.default_node_pool.os_disk_size_gb
  default_np_tags            = lookup(var.default_node_pool, "tags", null) == null ? var.default_np_tags : var.default_node_pool.tags
  default_np_type            = lookup(var.default_node_pool, "type", null) == null ? var.default_np_type : var.default_node_pool.type
  default_np_vm_size         = lookup(var.default_node_pool, "vm_size", null) == null ? var.default_np_vm_size : var.default_node_pool.vm_size

  network_dns_service_ip     = lookup(var.network_profile, "dns_service_ip", null) == null ? var.network_dns_service_ip : var.network_profile.dns_service_ip
  network_docker_bridge_cidr = lookup(var.network_profile, "docker_bridge_cidr", null) == null ? var.network_docker_bridge_cidr : var.network_profile.docker_bridge_cidr
  network_lb_sku             = lookup(var.network_profile, "load_balancer_sku", null) == null ? var.network_lb_sku : var.network_profile.load_balancer_sku
  network_plugin             = lookup(var.network_profile, "network_plugin", null) == null ? var.network_plugin : var.network_profile.network_plugin
  network_service_cidr       = lookup(var.network_profile, "service_cidr", null) == null ? var.network_service_cidr : var.network_profile.service_cidr

  aks_version                = lookup(var.kubernetes_cluster, "kubernetes_version", null) == null ? var.aks_version : var.kubernetes_cluster.kubernetes_version
  aks_rbac_enabled           = lookup(var.kubernetes_cluster, "rbac_enabled", null) == null ? var.aks_rbac_enabled : var.kubernetes_cluster.rbac_enabled
  aks_oms_agent_enabled      = lookup(var.kubernetes_cluster, "oms_agent_enabled", null) == null ? var.aks_oms_agent_enabled : var.kubernetes_cluster.oms_agent_enabled
  aks_kube_dashboard_enabled = lookup(var.kubernetes_cluster, "kube_dashboard_enabled", null) == null ? var.aks_kube_dashboard_enabled : var.kubernetes_cluster.kube_dashboard_enabled
  aks_azure_policy_enabled   = lookup(var.kubernetes_cluster, "azure_policy_enabled", null) == null ? var.aks_azure_policy_enabled : var.kubernetes_cluster.azure_policy_enabled
}
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "random_id" "log_analytics_ws_name_suffix" {
  byte_length = 4
}

resource "azurerm_log_analytics_workspace" "testk8s" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${local.log_analytics_ws_name}-${random_id.log_analytics_ws_name_suffix.dec}"
  location            = local.region.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  sku                 = local.log_analytics_ws_sku
  retention_in_days   = local.log_analytics_ws_retention
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "test_sol" {
  solution_name         = local.log_analytics_sol_name
  location              = local.region.name
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  workspace_resource_id = azurerm_log_analytics_workspace.testk8s.id
  workspace_name        = azurerm_log_analytics_workspace.testk8s.name
  plan {
    publisher = local.log_analytics_sol_publisher
    product   = local.log_analytics_sol_product
  }
}

data "azurerm_virtual_network" "cluster_vnet" {
  name                = local.vnet_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

data "azurerm_subnet" "cluster_subnet" {
  name                 = local.vnet_subnet_name
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = data.azurerm_virtual_network.cluster_vnet.name
}

resource "azurerm_kubernetes_cluster" "sachin-testcluster" {
  name                = var.kubernetes_cluster.name
  location            = local.region.name
  dns_prefix          = var.kubernetes_cluster.dns_prefix
  resource_group_name = data.azurerm_resource_group.resource_group.name
  kubernetes_version  = local.aks_version

  linux_profile {
    admin_username = var.linux_profile.admin_username
    ssh_key {
      key_data = file(var.linux_profile.ssh_key_file_path)
    }
  }

  default_node_pool {
    name                  = local.default_np_name
    enable_auto_scaling   = local.default_np_auto_scaling
    enable_node_public_ip = local.default_np_node_pip
    max_count             = local.default_np_max_count
    max_pods              = local.default_np_max_pods
    min_count             = local.default_np_min_count
    node_count            = local.default_np_node_count
    os_disk_size_gb       = local.default_np_os_disk_size_gb
    tags                  = local.default_np_tags
    type                  = local.default_np_type
    vm_size               = local.default_np_vm_size
    vnet_subnet_id        = data.azurerm_subnet.cluster_subnet.id
  }

  network_profile {
    network_plugin     = local.network_plugin
    dns_service_ip     = local.network_dns_service_ip
    docker_bridge_cidr = local.network_docker_bridge_cidr
    service_cidr       = local.network_service_cidr
    load_balancer_sku  = local.network_lb_sku
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

    role_based_access_control_enabled = true
}
