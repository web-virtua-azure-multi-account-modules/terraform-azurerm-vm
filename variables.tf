variable "name" {
  description = "Virtual machine name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "vm_size" {
  description = "VM type, default Standard_DS1_v2, to see other types https://learn.microsoft.com/pt-br/azure/virtual-machines/sizes"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "delete_os_disk_on_termination" {
  description = "Delete OS disk on termination"
  type        = bool
  default     = true
}

variable "delete_data_disks_on_termination" {
  description = "Delete data disks on termination"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Security group list"
  type        = list(string)
  default     = []
}

variable "is_public" {
  description = "If true will create the public IPs and attached on virtual machine, if public_ip variable is defined not be created a new public IP, will be used the public IP seted on public_ip variable"
  type        = bool
  default     = false
}

variable "public_ip" {
  description = "Public IP, if defined not will be created the new IPs and will be used these"
  type        = string
  default     = null
}

variable "ultra_ssd_enabled" {
  description = "If true ultra SSD will be enabled"
  type        = string
  default     = null
}

variable "os_profile_computer_name" {
  description = "Specifies the name of the Virtual Machine. Changing this forces a new resource to be created"
  type        = string
  default     = null
}

variable "os_profile_admin_username" {
  description = "Specifies the name of the local administrator account"
  type        = string
  default     = "azureuser"
}

variable "os_profile_admin_password" {
  description = "(Optional for Windows, Optional for Linux) The password associated with the local administrator account"
  type        = string
  default     = ""
}

variable "use_tags_default" {
  description = "If true will be use the tags default to resources"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to virtual machine"
  type        = map(any)
  default     = {}
}

variable "license_type" {
  description = "Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server"
  type        = string
  default     = null
}

variable "primary_network_interface_id" {
  description = "The ID of the Network Interface (which must be attached to the Virtual Machine) which should be the Primary Network Interface for this Virtual Machine"
  type        = string
  default     = null
}

variable "proximity_placement_group_id" {
  description = "The ID of the Proximity Placement Group to which this Virtual Machine should be assigned. Changing this forces a new resource to be created"
  type        = string
  default     = null
}

variable "zones" {
  description = "A list of a single item of the Availability Zone which the Virtual Machine should be allocated in. Changing this forces a new resource to be created"
  type        = list(string)
  default     = null
}

variable "storage_image_reference" {
  description = "Storage image reference"
  type = object({
    publisher = optional(string)
    offer     = optional(string)
    sku       = optional(string)
    version   = optional(string)
  })
}

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
  }
}

variable "os_profile_linux_config" {
  description = "If defined will be configurated a access SSH on Linux"
  type = object({
    disable_password_authentication = optional(bool, true)
    path                            = optional(string)
    key_data                        = optional(string)
  })
  default = null
}

variable "identity" {
  description = "Specifies the type of Managed Service Identity"
  type = object({
    type         = string
    identity_ids = optional(string)
    principal_id = optional(string)
  })
  default = null
}

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
  default = null
}

variable "os_profile_secrets" {
  description = "OS profile secrets"
  type = object({
    source_vault_id = string
    vault_certificates = optional(object({
      certificate_url   = string
      certificate_store = optional(string)
    }))
  })
  default = null
}

variable "plan" {
  description = "Product publisher plan"
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

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
  default = null
}

variable "boot_diagnostics" {
  description = "Boot diagnostics"
  type = object({
    enabled     = bool
    storage_uri = optional(string, "") # this url can receive a storage account URI
  })
  default = null
}
