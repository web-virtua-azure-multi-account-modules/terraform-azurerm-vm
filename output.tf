output "virtual_machine" {
  description = "Virtual machine"
  value       = azurerm_virtual_machine.create_virtual_machine
}

output "virtual_machine_id" {
  description = "Virtual machine ID"
  value       = azurerm_virtual_machine.create_virtual_machine.id
}

output "virtual_machine_name" {
  description = "Virtual machine name"
  value       = azurerm_virtual_machine.create_virtual_machine.name
}

output "public_ip" {
  description = "Public IP"
  value       = try(azurerm_public_ip.create_public_ip[0], null)
}

output "network_interface" {
  description = "Network interface"
  value       = azurerm_network_interface.create_network_interface
}
