variable "name" {
  description = "The name of the Linux Virtual Machine Scale Set. Changing this forces a new resource to be created."
  type        = string
  nullable    = false
}

variable "location" {
  description = "The Azure location where the Linux Virtual Machine Scale Set should exist. Changing this forces a new resource to be created."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "The name of the resource group where the Virtual Machine Scale Set is located."
  type        = string
  nullable    = false
}

variable "admin_username" {
  description = "The username of the local administrator on each Virtual Machine Scale Set instance. Changing this forces a new resource to be created."
  type        = string
}

variable "instances" {
  description = <<DESC
    The number of Virtual Machines in the Scale Set. Defaults to `0`.
    > **NOTE:** If you are using AutoScaling, you may wish to use Terraform's ignore_changes functionality to ignore changes to this field.
  DESC
  type        = number
  default     = null
}

variable "sku" {
  description = "The Virtual Machine SKU for the Scale Set, such as `Standard_F2s` or `Standard F4s`."
  type        = string
}

variable "network_interfaces" {
  description = <<DESC
    A list of one or more `network_interface` objects as defined below.
    A `network_interface` object supports the following:
      * name - (Required) The Name which should be used for this Network Interface. Changing this forces a new resource to be created.
      * ip_configuration - (Required) A list of `ip_configuration` objects as defined bwlow.
        An `ip_configuration` object supports the following:
          * name - (Required) The Name which should be used for this IP Configuration.
          * application_gateway_backend_address_pool_ids - (Optional) A list of Backend Address Pools ID`s from a Application Gateway which this Virtual Machine Scale Set should be connected to.
          * application_security_group_ids - (Optional) A list of Application Security Group ID`s which this Virtual Machine Scale Set should be connected to.
          * load_balancer_backend_address_pool_ids - (Optional) A list of Backend Address Pools ID`s from a Load Balancer which this Virtual Machine Scale Set should be connected to.
      * dns_servers - (Optional) A list of IP Addresses of DNS Servers which should be assigned to the Network Interface.
      * enable_accelerated_networking - (Optional) Does this Network Interface support Accelerated Networking? Defaults to false.
      * enable_ip_forwarding - (Optional) Does this Network Interface support IP Forwarding? Defaults to false.
      * network_security_group_id - (Optional) The ID of a Network Security Group which should be assigned to this Network Interface.
      * primary - (Optional) Is this the Primary IP Configuration? Defaults to false.
  DESC
  type = list(object({
    name = string
    ip_configuration = list(object({
      name                                         = string
      application_gateway_backend_address_pool_ids = optional(list(string))
      application_security_group_ids               = optional(list(string))
      load_balancer_backend_address_pool_ids       = optional(list(string))
    }))
    dns_servers                   = optional(list(string))
    enable_accelerated_networking = optional(bool)
    enable_ip_forwarding          = optional(bool)
    network_security_group_id     = optional(string)
    primary                       = optional(bool)
  }))
}

variable "os_disk" {
  description = <<DESC
    An `os_disk` object as defined below.
    An `os_disk` object supports the following:
      * caching - (Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`.
      * storage_account_type - (Required) The Type of Storage Account which should back this the Internal OS Disk. Possible values include `Standard_LRS`, `StandardSSD_LRS`, `StandardSSD_ZRS`, `Premium_LRS` and `Premium_ZRS`. Changing this forces a new resource to be created.
      * diff_disk_settings - (Optional) A `diff_disk_settings` object as defined above. Changing this forces a new resource to be created.
        A `diff_disk_settings` object supports the following:
          * option - (Required) Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is `Local`. Changing this forces a new resource to be created.
          * placement - (Optional) Specifies where to store the Ephemeral Disk. Possible values are `CacheDisk` and `ResourceDisk`. Defaults to `CacheDisk`. Changing this forces a new resource to be created.
      * disk_encryption_set_id - (Optional) The ID of the Disk Encryption Set which should be used to encrypt this OS Disk. Conflicts with secure_vm_disk_encryption_set_id. Changing this forces a new resource to be created.
      * disk_size_gb - (Optional) The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine Scale Set is sourced from.
      * secure_vm_disk_encryption_set_id - (Optional) The ID of the Disk Encryption Set which should be used to Encrypt the OS Disk when the Virtual Machine Scale Set is Confidential VMSS. Conflicts with disk_encryption_set_id. Changing this forces a new resource to be created.
      * security_encryption_type - (Optional) Encryption Type when the Virtual Machine Scale Set is Confidential VMSS. Possible values are `VMGuestStateOnly` and `DiskWithVMGuestState`. Changing this forces a new resource to be created.
      * write_accelerator_enabled - (Optional) Should Write Accelerator be Enabled for this OS Disk? Defaults to false.
  DESC
  type = object({
    caching              = string
    storage_account_type = string
    diff_disk_settings = optional(object({
      option    = string
      placement = optional(string)
    }))
    disk_encryption_set_id           = optional(string)
    disk_size_gb                     = optional(number)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type         = optional(string)
    write_accelerator_enabled        = optional(bool)
  })

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk.caching)
    error_message = "Invalid `var.os_disk.caching` possible values are `None`, `ReadOnly` and `ReadWrite`."
  }
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Premium_LRS", "Premium_ZRS"], var.os_disk.storage_account_type)
    error_message = "Invalid `var.os_disk.storage_account_type` possible values are `Standard_LRS`, `StandardSSD_LRS`, `StandardSSD_ZRS`, `Premium_LRS` and `Premium_ZRS`."
  }
  validation {
    condition     = try(contains(["Local"], var.os_disk.diff_disk_settings.option), true)
    error_message = "Invalid `var.os_disk.diff_disk_settings.option` possible values are `Local`."
  }
  validation {
    condition     = try(contains(["CacheDisk", "ResourceDisk"], var.os_disk.diff_disk_settings.placement), true)
    error_message = "Invalid `var.os_disk.diff_disk_settings.placement` possible values are `CacheDisk` and `ResourceDisk`."
  }
  validation {
    condition     = try(contains(["VMGuestStateOnly", "DiskWithVMGuestState"], var.os_disk.security_encryption_type), true)
    error_message = "Invalid `var.os_disk.security_encryption_type` possible values are `VMGuestStateOnly` and `DiskWithVMGuestState`."
  }
}

variable "additional_capabilities" {
  description = <<DESC
    An `additional_capabilities` object as defined below.
    An `additional_capabilities` object supports the following:
      * ultra_ssd_enabled - (Optional) Should the capacity to enable Data Disks of the `UltraSSD_LRS` storage account type be supported on this Virtual Machine Scale Set? Possible values are true or false. Defaults to false. Changing this forces a new resource to be created.
  DESC
  type = object({
    ultra_ssd_enabled = bool
  })
  default = null
}

variable "admin_password" {
  description = <<DESC
    The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created."
    > **NOTE:** When an `admin_password` is specified `disable_password_authentication` must be set to false.
    > **NOTE:** One of either `admin_password` or `admin_ssh_key` must be specified.
  DESC
  type        = string
  sensitive   = true
  default     = null
}

variable "admin_ssh_keys" {
  description = <<DESC
    A list of one or more `admin_ssh_key` objects as defined below.
    An `admin_ssh_key` object supports the following:
      * public_key - (Required) The Public Key which should be used for authentication, which needs to be at least 2048-bit and in ssh-rsa format.
      * username - (Required) The Username for which this Public SSH Key should be configured.
    > **NOTE:** One of either `admin_password` or `admin_ssh_key` must be specified.
    > **NOTE:** The Azure VM Agent only allows creating SSH Keys at the path `/home/{username}/.ssh/authorized_keys` - as such this public key will be added/appended to the authorized keys file.
  DESC
  type = list(object({
    public_key = string
    username   = string
  }))
  sensitive = true
  default   = null
}

variable "automatic_os_upgrade_policy" {
  description = <<DESC
    An `automatic_os_upgrade_policy` object as defined below. This can only be specified when upgrade_mode is set to either Automatic or Rolling.
    An `automatic_os_upgrade_policy` object supports the following:
      * disable_automatic_rollback - (Required) Should automatic rollbacks be disabled?
      * enable_automatic_os_upgrade - (Required) Should OS Upgrades automatically be applied to Scale Set instances in a rolling fashion when a newer version of the OS Image becomes available?
  DESC
  type = object({
    disable_automatic_rollback  = bool
    enable_automatic_os_upgrade = bool
  })
  default = null
}

variable "automatic_instance_repair" {
  description = <<DESC
    An `automatic_instance_repair` object as defined below. To enable the automatic instance repair, this Virtual Machine Scale Set must have a valid `health_probe_id` or an Application Health Extension.
    An `automatic_instance_repair` block supports the following:
      * enabled - (Required) Should the automatic instance repair be enabled on this Virtual Machine Scale Set?
      * grace_period - (Optional) Amount of time (in minutes, between 30 and 90) for which automatic repairs will be delayed. The grace period starts right after the VM is found unhealthy. The time duration should be specified in ISO 8601 format. Defaults to `PT30M`.
  DESC
  type = object({
    enabled      = bool
    grace_period = optional(string, "PT30M")
  })
  default = null
}

variable "boot_diagnostics" {
  description = <<DESC
    A `boot_diagnostics` object as defined below.
    A `boot_diagnostics` object supports the following:
      * storage_account_uri - (Optional) The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor.  
      > **NOTE:** Passing a null value will utilize a Managed Storage Account to store Boot Diagnostics.
  DESC
  type = object({
    storage_account_uri = string
  })
  default = null
}

variable "capacity_reservation_group_id" {
  description = <<DESC
    Specifies the ID of the Capacity Reservation Group which the Virtual Machine Scale Set should be allocated to. Changing this forces a new resource to be created.
    > **NOTE:** `capacity_reservation_group_id` cannot be used with `proximity_placement_group_id`
    > **NOTE:** `single_placement_group` must be set to `false` when `capacity_reservation_group_id` is specified.
  DESC
  type        = string
  default     = null
}

variable "computer_name_prefix" {
  description = "The prefix which should be used for the name of the Virtual Machines in this Scale Set. If unspecified this defaults to the value for the name field. If the value of the name field is not a valid `computer_name_prefix`, then you must specify `computer_name_prefix`. Changing this forces a new resource to be created."
  type        = string
  default     = bool
}

variable "custom_data" {
  description = <<DESC
    The Base64-Encoded Custom Data which should be used for this Virtual Machine Scale Set.
    > **NOTE:** When Custom Data has been configured, it's not possible to remove it without tainting the Virtual Machine Scale Set, due to a limitation of the Azure API.
  DESC
  type        = string
  default     = null
}

variable "data_disk" {
  description = <<DESC
    A list of one or more `data_disk` objects as defined below.
    A `data_disk` object supports the following:
      * name - (Optional) The name of the Data Disk.
      * caching - (Required) The type of Caching which should be used for this Data Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`.
      * create_option - (Optional) The create option which should be used for this Data Disk. Possible values are `Empty` and `FromImage`. Defaults to `Empty`. (FromImage should only be used if the source image includes data disks).
      * disk_size_gb - (Required) The size of the Data Disk which should be created.
      * lun - (Required) The Logical Unit Number of the Data Disk, which must be unique within the Virtual Machine.
      * storage_account_type - (Required) The Type of Storage Account which should back this Data Disk. Possible values include `Standard_LRS`, `StandardSSD_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `PremiumV2_LRS`, `Premium_ZRS` and `UltraSSD_LRS`.
        > **NOTE:** `UltraSSD_LRS` is only supported when `ultra_ssd_enabled` within the `additional_capabilities` variable is enabled.
      * disk_encryption_set_id - (Optional) The ID of the Disk Encryption Set which should be used to encrypt this Data Disk. Changing this forces a new resource to be created.
        > **NOTE:** The Disk Encryption Set must have the `Reader` Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault
      * ultra_ssd_disk_iops_read_write - (Optional) Specifies the Read-Write IOPS for this Data Disk. Only settable when `storage_account_type` is `PremiumV2_LRS` or `UltraSSD_LRS`.
      * ultra_ssd_disk_mbps_read_write - (Optional) Specifies the bandwidth in MB per second for this Data Disk. Only settable when `storage_account_type` is `PremiumV2_LRS` or `UltraSSD_LRS`.
      * write_accelerator_enabled - (Optional) Should Write Accelerator be enabled for this Data Disk? Defaults to `false`.
        > **NOTE:** This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`.
  DESC
  type = list(object({
    name                           = optional(string)
    caching                        = string
    create_option                  = optional(string)
    disk_size_gb                   = number
    lun                            = number
    storage_account_type           = string
    disk_encryption_set_id         = optional(string)
    ultra_ssd_disk_iops_read_write = optional(number)
    ultra_ssd_disk_mbps_read_write = optional(number)
    write_accelerator_enabled      = optional(bool)
  }))
  default = null

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.data_disk.caching)
    error_message = "Invalid `var.data_disk.caching` possible values are `None`, `ReadOnly` and `ReadWrite`."
  }
  validation {
    condition     = try(contains(["Empty", "FromImage"], var.data_disk.create_option), true)
    error_message = "Invalid `var.data_disk.create_option` possible values are `Empty` and `FromImage`."
  }
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Premium_LRS", "Premium_ZRS"], var.data_disk.storage_account_type)
    error_message = "Invalid `var.data_disk.storage_account_type` possible values are `Standard_LRS`, `StandardSSD_LRS`, `StandardSSD_ZRS`, `Premium_LRS` and `Premium_ZRS`."
  }
}

variable "disable_password_authentication" {
  description = <<DESC
    Should Password Authentication be disabled on this Virtual Machine Scale Set? Defaults to true.
    > **NOTE:** When a `admin_password` is specified `disable_password_authentication` must be set to false
  DESC
  type        = bool
  default     = null
}

variable "do_not_run_extensions_on_overprovisioned_machines" {
  description = "Should Virtual Machine Extensions be run on Overprovisioned Virtual Machines in the Scale Set? Defaults to false."
  type        = bool
  default     = null
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Linux Virtual Machine Scale Set should exist. Changing this forces a new Linux Virtual Machine Scale Set to be created."
  type        = string
  default     = null
}

variable "encryption_at_host_enabled" {
  description = "Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  type        = bool
  default     = null
}

variable "extensions" {
  description = <<DESC
    A list of one or more extension objects as defined below.
    An extension object supports the following:
      * name - (Required) The name for the Virtual Machine Scale Set Extension.
      * publisher - (Required) Specifies the Publisher of the Extension.
      * type - (Required) Specifies the Type of the Extension.
      * type_handler_version - (Required) Specifies the version of the extension to use, available versions can be found using the Azure CLI.
      * auto_upgrade_minor_version - (Optional) Should the latest version of the Extension be used at Deployment Time, if one is available? This won't auto-update the extension on existing installation. Defaults to `true`.
      * automatic_upgrade_enabled - (Optional) Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension? Defaults to `true`.
      * force_update_tag - (Optional) A value which, when different to the previous value can be used to force-run the Extension even if the Extension Configuration hasn't changed.
      * protected_settings - (Optional) A JSON String which specifies Sensitive Settings (such as Passwords) for the Extension.
        > **NOTE:** Keys within the `protected_settings` block are notoriously case-sensitive, where the casing required (e.g. TitleCase vs snakeCase) depends on the Extension being used. Please refer to the documentation for the specific Virtual Machine Extension you're looking to use for more information.
        > **NOTE:**Rather than defining JSON inline you can use the jsonencode interpolation function to define this in a cleaner way.
      * protected_settings_from_key_vault - (Optional) A `protected_settings_from_key_vault` block as defined below.
        A `protected_settings_from_key_vault` block supports the following:
          * secret_url - (Required) The URL to the Key Vault Secret which stores the protected settings.
          * source_vault_id - (Required) The ID of the source Key Vault.
        > **NOTE:** `protected_settings_from_key_vault` cannot be used with `protected_settings``
      * provision_after_extensions - (Optional) An ordered list of Extension names which this should be provisioned after.
      * settings - (Optional) A JSON String which specifies Settings for the Extension.
        > **NOTE:** Keys within the `settings` block are notoriously case-sensitive, where the casing required (e.g. TitleCase vs snakeCase) depends on the Extension being used. Please refer to the documentation for the specific Virtual Machine Extension you're looking to use for more information.
        > **NOTE:**Rather than defining JSON inline you can use the jsonencode interpolation function to define this in a cleaner way.
  DESC
  type = list(object({
    name                       = string
    publisher                  = string
    type                       = string
    type_handler_version       = string
    auto_upgrade_minor_version = optional(bool)
    automatic_upgrade_enabled  = optional(bool)
    force_update_tag           = optional(bool)
    protected_settings         = optional(string)
    protected_settings_from_key_vault = optional(object({
      secret_url      = string
      source_vault_id = string
    }))
    provision_after_extensions = optional(list(string))
    settings                   = optional(string)
  }))
  sensitive = true
  default   = null
}

variable "extension_operations_enabled" {
  description = <<DESC
    Should extension operations be allowed on the Virtual Machine Scale Set? Possible values are `true` or `false`. Defaults to `true`. Changing this forces a new Linux Virtual Machine Scale Set to be created.
    > **NOTE:** `extension_operations_enabled` may only be set to `false` if there are no extensions defined in the `extensions` variable.
  DESC
  type        = bool
  default     = null
}

variable "extensions_time_budget" {
  description = "Specifies the duration allocated for all extensions to start. The time duration should be between `15` minutes and `120` minutes (inclusive) and should be specified in ISO 8601 format. Defaults to `PT1H30M`."
  type        = string
  default     = null
}

variable "eviction_policy" {
  description = <<DESC
    Specifies the eviction policy for Virtual Machines in this Scale Set. Possible values are `Deallocate` and `Delete`. Changing this forces a new resource to be created."
    > **NOTE:** This can only be configured when priority is set to Spot.
  DESC
  type        = string
  default     = null

  validation {
    condition     = try(contains(["Deallocate", "Delete"], var.data_disk.create_option), true)
    error_message = "Invalid `var.eviction_policy` possible values are `Deallocate` and `Delete`."
  }
}

variable "gallery_applications" {
  description = <<DESC
    A list of one or more `gallery_application` objects as defined below.
    A `gallery_application` object supports the following:
      * version_id - (Required) Specifies the Gallery Application Version resource ID. Changing this forces a new resource to be created.
      * configuration_blob_uri - (Optional) Specifies the URI to an Azure Blob that will replace the default configuration for the package if provided. Changing this forces a new resource to be created.
      * order - (Optional) Specifies the order in which the packages have to be installed. Possible values are between 0 and 2,147,483,647. Changing this forces a new resource to be created.
      * tag - (Optional) Specifies a passthrough value for more generic context. This field can be any valid string value. Changing this forces a new resource to be created.
  DESC
  type = list(object({
    version_id            = string
    configuration_blob_uri = optional(string)
    order                 = optional(number)
    tag                   = optional(string)
  }))
  default = null
}

variable "health_probe_id" {
  description = "The ID of a Load Balancer Probe which should be used to determine the health of an instance. This is Required and can only be specified when `upgrade_mode` is set to `Automatic` or `Rolling`."
  type        = string
  default     = null
}

variable "host_group_id" {
  description = "Specifies the ID of the dedicated host group that the virtual machine scale set resides in. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "identity" {
  description = <<DESC
    An identity object as defined below.
    An identity object supports the following:
      * type - (Required) Specifies the type of Managed Service Identity that should be configured on this Linux Virtual Machine Scale Set. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned` (to enable both).
      * identity_ids - (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Linux Virtual Machine Scale Set.
        > **NOTE:** This is required when type is set to UserAssigned or SystemAssigned, UserAssigned.
  DESC
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition     = try(contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type), true)
    error_message = "Invalid `var.identity.type` possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`."
  }
}

variable "max_bid_price" {
  description = <<DESC
    The maximum price you're willing to pay for each Virtual Machine in this Scale Set, in US Dollars; which must be greater than the current spot price. If this bid price falls below the current spot price the Virtual Machines in the Scale Set will be evicted using the `eviction_policy`. Defaults to `-1`, which means that each Virtual Machine in this Scale Set should not be evicted for price reasons."
    > **NOTE:** This can only be configured when `priority` is set to `Spot`.
  DESC
  type        = number
  default     = null
}

variable "overprovision" {
  description = "Should Azure over-provision Virtual Machines in this Scale Set? This means that multiple Virtual Machines will be provisioned and Azure will keep the instances which become available first - which improves provisioning success rates and improves deployment time. You're not billed for these over-provisioned VM's and they don't count towards the Subscription Quota. Defaults to `true`."
  type        = bool
  default     = null
}

variable "plan" {
  description = <<DESC
    A `plan` object as defined below. Changing this forces a new resource to be created.
    A `plan` object supports the following:
      * name - (Required) Specifies the name of the image from the marketplace. Changing this forces a new resource to be created.
      * publisher - (Required) Specifies the publisher of the image. Changing this forces a new resource to be created.
      * product - (Required) Specifies the product of the image from the marketplace. Changing this forces a new resource to be created.
    > **NOTE:** When using an image from Azure Marketplace a plan must be specified.
  DESC
  type = object({
    name      = string
    publisher = string
    product   = string
  })
  default = null
}

variable "platform_fault_domain_count" {
  type        = number
  description = "Specifies the number of fault domains that are used by this Linux Virtual Machine Scale Set. Changing this forces a new resource to be created."
  default     = null
}

variable "priority" {
  description = <<DESC
    The Priority of this Virtual Machine Scale Set. Possible values are `Regular` and `Spot`. Defaults to `Regular`. Changing this value forces a new resource.
    > **NOTE:** When priority is set to Spot an eviction_policy must be specified.
  DESC
  type        = string
  default     = null

  validation {
    condition     = try(contains(["Regular", "Spot"], var.identity.type), true)
    error_message = "Invalid `var.priority` possible values are `SystemAssigned` and `Spot`."
  }
}

variable "provision_vm_agent" {
  description = "Should the Azure VM Agent be provisioned on each Virtual Machine in the Scale Set? Defaults to `true`. Changing this value forces a new resource to be created."
  type        = bool
  default     = null
}

variable "proximity_placement_group_id" {
  description = "The ID of the Proximity Placement Group in which the Virtual Machine Scale Set should be assigned to. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "rolling_upgrade_policy" {
  description = <<DESC
    A `rolling_upgrade_policy` object as defined below. This is Required and can only be specified when `upgrade_mode` is set to `Automatic` or `Rolling`. Changing this forces a new resource to be created.
    A `rolling_upgrade_policy` object supports the following:
      * cross_zone_upgrades_enabled - (Optional) Should the Virtual Machine Scale Set ignore the Azure Zone boundaries when constructing upgrade batches? Possible values are `true` or `false`.
      * max_batch_instance_percent - (Required) The maximum percent of total virtual machine instances that will be upgraded simultaneously by the rolling upgrade in one batch. As this is a maximum, unhealthy instances in previous or future batches can cause the percentage of instances in a batch to decrease to ensure higher reliability.
      * max_unhealthy_instance_percent - (Required) The maximum percentage of the total virtual machine instances in the scale set that can be simultaneously unhealthy, either as a result of being upgraded, or by being found in an unhealthy state by the virtual machine health checks before the rolling upgrade aborts. This constraint will be checked prior to starting any batch.
      * max_unhealthy_upgraded_instance_percent - (Required) The maximum percentage of upgraded virtual machine instances that can be found to be in an unhealthy state. This check will happen after each batch is upgraded. If this percentage is ever exceeded, the rolling update aborts.
      * pause_time_between_batches - (Required) The wait time between completing the update for all virtual machines in one batch and starting the next batch. The time duration should be specified in ISO 8601 format.
      * prioritize_unhealthy_instances_enabled - (Optional) Upgrade all unhealthy instances in a scale set before any healthy instances. Possible values are `true` or `false`.
  DESC
  type = object({
    cross_zone_upgrades_enabled             = optional(bool)
    max_batch_instance_percent              = number
    max_unhealthy_instance_percent          = number
    max_unhealthy_upgraded_instance_percent = number
    pause_time_between_batches              = string
    prioritize_unhealthy_instances_enabled  = optional(bool)
  })
  default = null
}

variable "scale_in" {
  description = <<DESC
    A `scale_in` object as defined below.
    A `scale_in` object supports the following:
      * rule - (Optional) The scale-in policy rule that decides which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Possible values for the scale-in policy rules are `Default`, `NewestVM` and `OldestVM`, defaults to `Default`.
      * force_deletion_enabled - (Optional) Should the virtual machines chosen for removal be force deleted when the virtual machine scale set is being scaled-in? Possible values are `true` or `false`. Defaults to `false`.
  DESC
  type = object({
    rule                   = optional(string)
    force_deletion_enabled = optional(bool)
  })
  default = null

  validation {
    condition     = try(contains(["Default", "NewestVM", "OldestVM"], var.scale_in.rule), true)
    error_message = "Invalid `var.scale_in.rule` possible values are `Default`, `NewestVM` and `OldestVM`."
  }
}

variable "secrets" {
  description = <<DESC
    A list of one or more `secret` objects as defined below.
    A `secret` object supports the following:
      * certificate - (Required) A list of one or more `certificate` blocks as defined above.
        A `certificate` block supports the following:
          * url - (Required) The Secret URL of a Key Vault Certificate.
            > **NOTE:** This can be sourced from the `secret_id` field within the `azurerm_key_vault_certificate` Resource
            > **NOTE:** The certificate must have been uploaded/created in PFX format, PEM certificates are not currently supported by Azure.
      * key_vault_id - (Required) The ID of the Key Vault from which all Secrets should be sourced.
  DESC
  type = list(object({
    certificate = list(object({
      url = string
    }))
    key_vault_id = string
  }))
  default = null
}

variable "secure_boot_enabled" {
  type        = bool
  description = "Specifies whether secure boot should be enabled on the virtual machine. Changing this forces a new resource to be created."
  default     = null
}

variable "single_placement_group" {
  type        = bool
  description = "Should this Virtual Machine Scale Set be limited to a Single Placement Group, which means the number of instances will be capped at 100 Virtual Machines. Defaults to `true`."
  default     = null
}

variable "source_image_id" {
  description = <<DESC
    The ID of an Image which each Virtual Machine in this Scale Set should be based on. Possible Image ID types include `Image ID`, `Shared Image ID`, `Shared Image Version ID`, `Community Gallery Image ID`, `Community Gallery Image Version ID`, `Shared Gallery Image ID` and `Shared Gallery Image Version ID`."
    > **NOTE:** One of either `source_image_id` or `source_image_reference` must be set.
  DESC
  type        = string
  default     = null
}

variable "source_image_reference" {
  description = <<DESC
    A `source_image_reference` object as defined below.
      * publisher - (Required) Specifies the publisher of the image used to create the virtual machines. Changing this forces a new resource to be created.
      * offer - (Required) Specifies the offer of the image used to create the virtual machines. Changing this forces a new resource to be created.
      * sku - (Required) Specifies the SKU of the image used to create the virtual machines.
      * version - (Required) Specifies the version of the image used to create the virtual machines.
    > **NOTE:** One of either `source_image_id` or `source_image_reference` must be set.
  DESC
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "spot_restore" {
  description = <<DESC
    A `spot_restore` object as defined below.
    A spot_restore object supports the following:
      * enabled - (Optional) Should the Spot-Try-Restore feature be enabled? The Spot-Try-Restore feature will attempt to automatically restore the evicted Spot Virtual Machine Scale Set VM instances opportunistically based on capacity availability and pricing constraints. Possible values are `true` or `false`. Defaults to `false`. Changing this forces a new resource to be created.
      * timeout - (Optional) The length of time that the Virtual Machine Scale Set should attempt to restore the Spot VM instances which have been evicted. The time duration should be between `15` minutes and `120` minutes (inclusive). The time duration should be specified in the ISO 8601 format. Defaults to `PT1H`. Changing this forces a new resource to be created.
  DESC
  type = object({
    enabled = optional(bool)
    timeout = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags which should be assigned to this Virtual Machine Scale Set."
  type        = map(any)
  default     = null
}

variable "termination_notification" {
  description = <<DESC
    A `termination_notification` object as defined below.
    A `termination_notification` object supports the following:
      * enabled - (Required) Should the terminate notification be enabled on this Virtual Machine Scale Set?
      * timeout - (Optional) Length of time (in minutes, between 5 and 15) a notification to be sent to the VM on the instance metadata server till the VM gets deleted. The time duration should be specified in ISO 8601 format. Defaults to `PT5M`.
  DESC
  type = object({
    enabled = bool
    timeout = optional(string)
  })
  default = null
}

variable "upgrade_mode" {
  description = <<DESC
    Specifies how Upgrades (e.g. changing the Image/SKU) should be performed to Virtual Machine Instances. Possible values are `Automatic`, `Manual` and `Rolling`. Defaults to `Manual`. Changing this forces a new resource to be created.
    > **NOTE:** If rolling upgrades are configured and running on a Linux Virtual Machine Scale Set, they will be cancelled when Terraform tries to destroy the resource.
  DESC
  type        = string
  default     = null

  validation {
    condition     = try(contains(["Automatic", "Manual", "Rolling"], var.upgrade_mode), true)
    error_message = "Invalid `var.upgrade_modee` possible values are `Automatic`, `Manual` and `Rolling`."
  }
}

variable "user_data" {
  description = "The Base64-Encoded User Data which should be used for this Virtual Machine Scale Set."
  type        = string
  default     = null
}


variable "vtpm_enabled" {
  description = "Specifies whether vTPM should be enabled on the virtual machine. Changing this forces a new resource to be created."
  type        = bool
  default     = null
}

variable "zone_balance" {
  description = "Should the Virtual Machines in this Scale Set be strictly evenly distributed across Availability Zones? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = null
}

variable "zones" {
  description = "Specifies a list of Availability Zones in which this Linux Virtual Machine Scale Set should be located. Changing this forces a new Linux Virtual Machine Scale Set to be created."
  type        = list(number)
  default     = null
}
