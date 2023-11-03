locals {
  tags_virtual_machine = {
    "tf-name" = var.name
    "tf-type" = "vm"
  }
}

data "azurerm_resource_group" "get_resource_group" {
  name = var.resource_group_name
}

resource "azurerm_public_ip" "create_public_ip" {
  count = (var.is_public && var.public_ip == null) ? 1 : 0

  name                    = "${var.name}-static-ip-${count.index + 1}"
  resource_group_name     = data.azurerm_resource_group.get_resource_group.name
  location                = data.azurerm_resource_group.get_resource_group.location
  allocation_method       = var.static_ip_nat_configuration.allocation_method
  sku                     = var.static_ip_nat_configuration.sku
  zones                   = var.static_ip_nat_configuration.zones
  ddos_protection_mode    = var.static_ip_nat_configuration.ddos_protection_mode
  ddos_protection_plan_id = var.static_ip_nat_configuration.ddos_protection_plan_id
  domain_name_label       = var.static_ip_nat_configuration.domain_name_label
  edge_zone               = var.static_ip_nat_configuration.edge_zone
  idle_timeout_in_minutes = var.static_ip_nat_configuration.idle_timeout_in_minutes
  ip_tags                 = var.static_ip_nat_configuration.ip_tags
  ip_version              = var.static_ip_nat_configuration.ip_version
  public_ip_prefix_id     = var.static_ip_nat_configuration.public_ip_prefix_id
  reverse_fqdn            = var.static_ip_nat_configuration.reverse_fqdn
  sku_tier                = var.static_ip_nat_configuration.sku_tier
  tags                    = var.static_ip_nat_configuration.tags
}

resource "azurerm_network_interface" "create_network_interface" {
  resource_group_name           = data.azurerm_resource_group.get_resource_group.name
  location                      = data.azurerm_resource_group.get_resource_group.location
  name                          = var.network_interface_config.name != null ? var.network_interface_config.name : "${var.name}-net-interface"
  auxiliary_mode                = var.network_interface_config.auxiliary_mode
  auxiliary_sku                 = var.network_interface_config.auxiliary_sku
  dns_servers                   = var.network_interface_config.dns_servers
  edge_zone                     = var.network_interface_config.edge_zone
  enable_ip_forwarding          = var.network_interface_config.enable_ip_forwarding
  enable_accelerated_networking = var.network_interface_config.enable_accelerated_networking
  internal_dns_name_label       = var.network_interface_config.internal_dns_name_label
  tags                          = var.network_interface_config.tags

  ip_configuration {
    subnet_id                                          = var.subnet_id
    name                                               = var.network_interface_config.name != null ? "${var.network_interface_config.name}-ip-config" : "${var.name}-ip-config"
    private_ip_address_allocation                      = var.network_interface_config.private_ip_address_allocation
    private_ip_address                                 = var.network_interface_config.private_ip_address
    gateway_load_balancer_frontend_ip_configuration_id = var.network_interface_config.gateway_load_balancer_frontend_ip_configuration_id
    private_ip_address_version                         = var.network_interface_config.private_ip_address_version
    primary                                            = var.network_interface_config.primary
    public_ip_address_id                               = try(azurerm_public_ip.create_public_ip[0].id, var.public_ip)
  }
}

resource "azurerm_virtual_machine" "create_virtual_machine" {
  name                             = var.name
  resource_group_name              = data.azurerm_resource_group.get_resource_group.name
  location                         = data.azurerm_resource_group.get_resource_group.location
  network_interface_ids            = [azurerm_network_interface.create_network_interface.id]
  vm_size                          = var.vm_size
  license_type                     = var.license_type
  primary_network_interface_id     = var.primary_network_interface_id
  proximity_placement_group_id     = var.proximity_placement_group_id
  zones                            = var.zones
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disks_on_termination
  tags                             = merge(var.tags, var.use_tags_default ? local.tags_virtual_machine : {})

  storage_image_reference {
    publisher = var.storage_image_reference.publisher
    offer     = var.storage_image_reference.offer
    sku       = var.storage_image_reference.sku
    version   = var.storage_image_reference.version
  }

  storage_os_disk {
    name                      = var.storage_os_disk.name != null ? var.storage_os_disk.name : "${var.name}-disk"
    create_option             = var.storage_os_disk.create_option
    caching                   = var.storage_os_disk.caching
    managed_disk_type         = var.storage_os_disk.managed_disk_type
    disk_size_gb              = var.storage_os_disk.disk_size_gb
    image_uri                 = var.storage_os_disk.image_uri
    managed_disk_id           = var.storage_os_disk.managed_disk_id
    os_type                   = var.storage_os_disk.os_type
    vhd_uri                   = var.storage_os_disk.vhd_uri
    write_accelerator_enabled = var.storage_os_disk.write_accelerator_enabled
  }

  dynamic "os_profile" {
    for_each = (var.os_profile_computer_name != null || var.os_profile_admin_username != null || var.os_profile_admin_password != null) ? [1] : []

    content {
      computer_name  = var.os_profile_computer_name != null ? var.os_profile_computer_name : var.name
      admin_username = var.os_profile_admin_username
      admin_password = var.os_profile_admin_password
    }
  }

  dynamic "os_profile_linux_config" {
    for_each = var.os_profile_linux_config != null ? [1] : []

    content {
      disable_password_authentication = var.os_profile_linux_config.disable_password_authentication
      ssh_keys {
        path     = var.os_profile_linux_config.path != null ? var.os_profile_linux_config.path : "/home/${var.os_profile_admin_username}/.ssh/authorized_keys"
        key_data = var.os_profile_linux_config.key_data
      }
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics != null ? [1] : []

    content {
      enabled     = var.boot_diagnostics.enabled
      storage_uri = var.boot_diagnostics.storage_uri
    }
  }

  dynamic "os_profile_windows_config" {
    for_each = var.os_profile_windows_config != null ? [1] : []

    content {
      enable_automatic_upgrades = var.os_profile_windows_config.enable_automatic_upgrades
      provision_vm_agent        = var.os_profile_windows_config.provision_vm_agent
      timezone                  = var.os_profile_windows_config.timezone

      dynamic "additional_unattend_config" {
        for_each = var.os_profile_windows_config.additional_unattend_config != null ? [1] : []

        content {
          pass         = var.os_profile_windows_config.additional_unattend_config.pass
          component    = var.os_profile_windows_config.additional_unattend_config.component
          setting_name = var.os_profile_windows_config.additional_unattend_config.setting_name
          content      = var.os_profile_windows_config.additional_unattend_config.content
        }
      }

      dynamic "winrm" {
        for_each = var.os_profile_windows_config.winrm != null ? [1] : []

        content {
          certificate_url = var.os_profile_windows_config.winrm.certificate_url
          protocol        = var.os_profile_windows_config.winrm.protocol
        }
      }
    }
  }

  dynamic "additional_capabilities" {
    for_each = var.ultra_ssd_enabled != null ? [1] : []

    content {
      ultra_ssd_enabled = var.ultra_ssd_enabled
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [1] : []

    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
      principal_id = var.identity.principal_id
    }
  }

  dynamic "os_profile_secrets" {
    for_each = var.os_profile_secrets != null ? [1] : []

    content {
      source_vault_id = var.os_profile_secrets.source_vault_id

      dynamic "vault_certificates" {
        for_each = var.os_profile_secrets.vault_certificates != null ? [1] : []

        content {
          certificate_url   = var.os_profile_secrets.vault_certificates.certificate_url
          certificate_store = var.os_profile_secrets.vault_certificates.certificate_store
        }
      }
    }
  }

  dynamic "plan" {
    for_each = var.plan != null ? [1] : []

    content {
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
    }
  }

  dynamic "storage_data_disk" {
    for_each = var.storage_data_disk != null ? [1] : []

    content {
      create_option             = var.storage_data_disk.create_option
      lun                       = var.storage_data_disk.lun
      name                      = var.storage_data_disk.name
      caching                   = var.storage_data_disk.caching
      disk_size_gb              = var.storage_data_disk.disk_size_gb
      managed_disk_id           = var.storage_data_disk.managed_disk_id
      managed_disk_type         = var.storage_data_disk.managed_disk_type
      vhd_uri                   = var.storage_data_disk.vhd_uri
      write_accelerator_enabled = var.storage_data_disk.write_accelerator_enabled
    }
  }
}

resource "azurerm_network_interface_security_group_association" "create_network_interface_security_group_association" {
  count = length(var.security_group_ids)

  network_interface_id      = azurerm_network_interface.create_network_interface.id
  network_security_group_id = var.security_group_ids[count.index]
}
