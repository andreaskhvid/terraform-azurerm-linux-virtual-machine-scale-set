output "name" {
  description = "The name of this Linux Virtual Machine Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Linux Virtual Machine Scale Set exist."
  value       = azurerm_linux_virtual_machine_scale_set.this.resource_group_name
}

output "id" {
  description = "The ID of the Linux Virtual Machine Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "location" {
  description = "The Azure location where the Linux Virtual Machine Scale Set exist."
  value       = azurerm_linux_virtual_machine_scale_set.this.location
}

output "identity" {
  description = <<DESCRIPTION
A identity block as defined below.
An identity block exports the following:

- type - The type of Managed Service Identity that is configured on this Virtual Machine Scale Set.
- principal_id - The Principal ID of the System Assigned Managed Service Identity that is configured on this Virtual Machine Scale Set.
- tenant_id - The Tenant ID of the System Assigned Managed Service Identity that is configured on this Virtual Machine Scale Set.
- identity_ids - The list of User Assigned Managed Identity IDs assigned to this Virtual Machine Scale Set.

DESCRIPTION
  value       = var.identity == null ? tomap(null) : azurerm_linux_virtual_machine_scale_set.this.identity[0]
}

output "network_interfaces" {
  description = <<DESCRIPTION
A list of network_interface blocks as defined below.
network_interface exports the following:

- name - The name of the network interface configuration.
- primary - Whether network interfaces created from the network interface configuration will be the primary NIC of the VM.
- ip_configuration - An `ip_configuration` block as documented below.

  `ip_configuration`exports the following:

  - name - The name of the IP configuration.
  - subnet_id - The the identifier of the subnet.
  - application_gateway_backend_address_pool_ids - An array of references to backend address pools of application gateways.
  - load_balancer_backend_address_pool_ids - An array of references to backend address pools of load balancers.
  - load_balancer_inbound_nat_rules_ids - An array of references to inbound NAT pools for load balancers.
  - primary - If this ip_configuration is the primary one.
  - application_security_group_ids - The application security group IDs to use.
  - public_ip_address - The virtual machines scale set IP Configuration's PublicIPAddress configuration. The `public_ip_address` is documented below.

    `public_ip_address` exports the following:

    - name - The name of the public IP address configuration
    - idle_timeout_in_minutes - The idle timeout in minutes.
    - domain_name_label - The domain name label for the DNS settings.
    - ip_tag - A list of ip_tag blocks as defined below.

      ip_tag exports the following:

      - tag - The IP Tag associated with the Public IP.
      - type - The Type of IP Tag.

    - public_ip_prefix_id - The ID of the public IP prefix.
    - version - The Internet Protocol Version of the public IP address.

- enable_accelerated_networking - Whether to enable accelerated networking or not.
- dns_servers - An array of the DNS servers in use.
- enable_ip_forwarding - Whether IP forwarding is enabled on this NIC.
- network_security_group_id - The identifier for the network security group.
DESCRIPTION
  value       = azurerm_linux_virtual_machine_scale_set.this.network_interface
}
