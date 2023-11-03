# Azure Virtual Machine for multiples accounts with Terraform module
* This module simplifies creating and configuring of Virtual Machine across multiple accounts on Azure

* Is possible use this module with one account using the standard profile or multi account using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Criate file provider.tf with the exemple code below:
```hcl
provider "azurerm" {
  alias   = "alias_profile_a"

  features {}
}

provider "azurerm" {
  alias   = "alias_profile_b"

  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}
```


## Features enable of Virtual Machine configurations for this module:

- Virtual machine
- Public IP
- Network interface

## Usage exemples


### Create Linux Virtual Machine with IP existing

```hcl
module "vm_test_linux" {
  "web-virtua-azure-multi-account-modules/vm/azurerm"

  name                = "tf-test-linux"
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  security_group_ids  = [var.security_group_id]
  is_public           = true
  public_ip           = azurerm_public_ip.create_public_ips.id

  storage_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  storage_os_disk = {
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 30
  }

  os_profile_linux_config = {
    key_data = var.public_rsa
  }

  providers = {
    azurerm = azurerm.alias_profile_b
  }
}
```

### Create Windows Virtual Machine and creating a new public IP

```hcl
module "vm_test_windows" {
  "web-virtua-azure-multi-account-modules/vm/azurerm"

  name                = "tf-test-windows"
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  security_group_ids  = [var.security_group_id]
  is_public           = true

  storage_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  storage_os_disk = {
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 130
  }

  os_profile_computer_name  = "tftestwindows1"
  os_profile_admin_username = "adminuser"
  os_profile_admin_password = "YourUser@23"

  os_profile_windows_config = {
    enable_automatic_upgrades = false
    provision_vm_agent        = false
  }

  providers = {
    azurerm = azurerm.alias_profile_a
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| name | `string` | `-` | yes | Virtual machine name | `-` |
| resource_group_name | `string` | `-` | yes | Resource group name | `-` |
| subnet_id | `string` | `-` | yes | Subnet ID | `-` |
| vm_size | `string` | `Standard_DS1_v2` | no | VM type, default Standard_DS1_v2, to see other types https://learn.microsoft.com/pt-br/azure/virtual-machines/sizes | `-` |
| delete_os_disk_on_termination | `bool` | `true` | no | Delete OS disk on termination | `*`false <br> `*`true |
| delete_data_disks_on_termination | `bool` | `true` | no | Delete data disks on termination | `*`false <br> `*`true |
| security_group_ids | `list(string)` | `[]` | no | Security group list | `-` |
| is_public | `bool` | `false` | no | If true will create the public IPs and attached on virtual machine, if public_ip variable is defined not be created a new public IP, will be used the public IP seted on public_ip variable | `*`false <br> `*`true |
| public_ip | `string` | `null` | no | Public IP, if defined not will be created the new IPs and will be used these | `-` |
| ultra_ssd_enabled | `string` | `null` | no | If true ultra SSD will be enabled | `-` |
| os_profile_computer_name | `string` | `null` | no | Specifies the name of the Virtual Machine. Changing this forces a new resource to be created | `-` |
| os_profile_admin_username | `string` | `azureuser` | no | Specifies the name of the local administrator account | `-` |
| os_profile_admin_password | `string` | `""` | no | (Optional for Windows, Optional for Linux) The password associated with the local administrator account | `-` |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to resources | `*`false <br> `*`true |
| tags | `map(any)` | `{}` | no | Tags to virtual virtual machine | `-` |
| license_type | `string` | `null` | no | Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server | `-` |
| primary_network_interface_id | `string` | `null` | no | The ID of the Network Interface (which must be attached to the Virtual Machine) which should be the Primary Network Interface for this Virtual Machine | `-` |
| proximity_placement_group_id | `string` | `null` | no | The ID of the Proximity Placement Group to which this Virtual Machine should be assigned. Changing this forces a new resource to be created | `-` |
| zones | `list(string)` | `null` | no | A list of a single item of the Availability Zone which the Virtual Machine should be allocated in. Changing this forces a new resource to be created | `-` |
| storage_image_reference | `object` | `-` | yes | Storage image reference | `-` |
| storage_os_disk | `object` | `object` | no | Storage OS disk | `-` |
| os_profile_linux_config | `object` | `null` | no | If defined will be configurated a access SSH on Linux | `-` |
| identity | `object` | `null` | no | Specifies the type of Managed Service Identity | `-` |
| static_ip_nat_configuration | `object` | `object` | no | Static IP NAT configuration | `-` |
| network_interface_config | `object` | `object` | no | Define the network interface configuration | `-` |
| os_profile_windows_config | `object` | `null` | no | If defined will be configurated a access Windows | `-` |
| os_profile_secrets | `object` | `null` | no | OS profile secrets | `-` |
| plan | `object` | `null` | no | Product publisher plan | `-` |
| storage_data_disk | `object` | `null` | no | Storage data disk | `-` |
| boot_diagnostics | `object` | `null` | no | Boot diagnostics | `-` |

* Model of storage_image_reference variable
```hcl
variable "storage_image_reference" {
  description = "Storage image reference"
  type = object({
    publisher = optional(string)
    offer     = optional(string)
    sku       = optional(string)
    version   = optional(string)
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
```

* Model of storage_os_disk variable
```hcl
variable "storage_os_disk" {
  description = "Storage OS disk"
  type = object({
    name                      = optional(string)
    disk_size_gb              = optional(string)
    create_option             = optional(string, "FromImage")
    caching                   = optional(string, "ReadWrite")
    managed_disk_type         = optional(string, "Standard_LRS")
    image_uri                 = optional(string)
    managed_disk_id           = optional(string)
    os_type                   = optional(string)
    vhd_uri                   = optional(string)
    write_accelerator_enabled = optional(string)
  })
  default = {
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 30
  }
}
```

* Model of os_profile_linux_config variable
```hcl
variable "os_profile_linux_config" {
  description = "If defined will be configurated a access SSH on Linux"
  type = object({
    disable_password_authentication = optional(bool, true)
    path                            = optional(string)
    key_data                        = optional(string)
  })
  default = {
    key_data = var.public_rsa
  }
}
```

* Model of identity variable
```hcl
variable "identity" {
  description = "Specifies the type of Managed Service Identity"
  type = object({
    type         = string
    identity_ids = optional(string)
    principal_id = optional(string)
  })
  default = {}
}
```

* Model of static_ip_nat_configuration variable
```hcl
variable "static_ip_nat_configuration" {
  description = "Static IP NAT configuration"
  type = object({
    allocation_method       = optional(string)
    sku                     = optional(string)
    zones                   = optional(list(string))
    ddos_protection_mode    = optional(string)
    ddos_protection_plan_id = optional(string)
    domain_name_label       = optional(string)
    edge_zone               = optional(string)
    idle_timeout_in_minutes = optional(number)
    ip_version              = optional(string)
    public_ip_prefix_id     = optional(string)
    reverse_fqdn            = optional(string)
    sku_tier                = optional(string)
    ip_tags                 = optional(map(any), {})
    tags                    = optional(map(any), {})
  })
  default = {
    allocation_method = "Static"
    sku               = "Standard"
  }
}
```

* Model of network_interface_config variable
```hcl
variable "network_interface_config" {
  description = "Define the network interface configuration"
  type = object({
    name                                               = optional(string)
    auxiliary_mode                                     = optional(string)
    auxiliary_sku                                      = optional(string)
    dns_servers                                        = optional(list(string))
    edge_zone                                          = optional(string)
    enable_ip_forwarding                               = optional(bool)
    enable_accelerated_networking                      = optional(bool)
    internal_dns_name_label                            = optional(string)
    tags                                               = optional(map(any), {})
    private_ip_address_allocation                      = optional(string, "Dynamic")
    private_ip_address                                 = optional(string)
    gateway_load_balancer_frontend_ip_configuration_id = optional(string)
    private_ip_address_version                         = optional(string)
    primary                                            = optional(bool)
  })
  default = {
    private_ip_address_allocation = "Dynamic"
  }
}
```

* Model of os_profile_windows_config variable
```hcl
variable "os_profile_windows_config" {
  description = "If defined will be configurated a access Windows"
  type = object({
    enable_automatic_upgrades = optional(bool)
    provision_vm_agent        = optional(bool)
    timezone                  = optional(string)

    additional_unattend_config = optional(object({
      pass         = string
      component    = string
      setting_name = string
      content      = string
    }))

    winrm = optional(object({
      certificate_url = optional(string)
      protocol        = string
    }))
  })
  default = {
    enable_automatic_upgrades = false
    provision_vm_agent        = false
  }
}
```

* Model of os_profile_secrets variable
```hcl
variable "os_profile_secrets" {
  description = "OS profile secrets"
  type = object({
    source_vault_id = string
    vault_certificates = optional(object({
      certificate_url   = string
      certificate_store = optional(string)
    }))
  })
  default = {}
}
```

* Model of plan variable
```hcl
variable "plan" {
  description = "Product publisher plan"
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = {}
}
```

* Model of storage_data_disk variable
```hcl
variable "storage_data_disk" {
  description = "Storage data disk"
  type = object({
    create_option             = string
    lun                       = number
    name                      = string
    caching                   = optional(string)
    disk_size_gb              = optional(number)
    managed_disk_id           = optional(string)
    managed_disk_type         = optional(string)
    vhd_uri                   = optional(string)
    write_accelerator_enabled = optional(bool)
  })
  default = {}
}
```

* Model of boot_diagnostics variable
```hcl
variable "boot_diagnostics" {
  description = "Boot diagnostics"
  type = object({
    enabled     = bool
    storage_uri = optional(string, "") # this url can receive a storage account URI
  })
  default = {}
}
```


## Resources

| Name | Type |
|------|------|
| [azurerm_public_ip.create_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_network_interface.create_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine.create_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_network_interface_security_group_association.create_network_interface_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `virtual_machine` | Virtual machine |
| `virtual_machine_id` | Virtual machine ID |
| `virtual_machine_name` | Virtual machine name |
| `public_ip` | Public IP |
| `network_interface` | Network interface |
