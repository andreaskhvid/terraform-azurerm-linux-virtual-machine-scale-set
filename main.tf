resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  admin_username                                    = var.admin_username
  instances                                         = var.instances
  sku                                               = var.sku
  admin_password                                    = var.admin_password
  capacity_reservation_group_id                     = var.capacity_reservation_group_id
  computer_name_prefix                              = var.computer_name_prefix
  custom_data                                       = var.custom_data
  disable_password_authentication                   = var.disable_password_authentication
  do_not_run_extensions_on_overprovisioned_machines = var.do_not_run_extensions_on_overprovisioned_machines
  edge_zone                                         = var.edge_zone
  encryption_at_host_enabled                        = var.encryption_at_host_enabled
  extension_operations_enabled                      = var.extension_operations_enabled
  extensions_time_budget                            = var.extensions_time_budget
  eviction_policy                                   = var.eviction_policy
  health_probe_id                                   = var.health_probe_id
  host_group_id                                     = var.host_group_id
  max_bid_price                                     = var.max_bid_price
  overprovision                                     = var.overprovision
  platform_fault_domain_count                       = var.platform_fault_domain_count
  priority                                          = var.priority
  provision_vm_agent                                = var.provision_vm_agent
  proximity_placement_group_id                      = var.proximity_placement_group_id
  secure_boot_enabled                               = var.secure_boot_enabled
  single_placement_group                            = var.single_placement_group
  source_image_id                                   = var.source_image_id
  tags                                              = var.tags
  upgrade_mode                                      = var.upgrade_mode
  user_data                                         = var.user_data
  vtpm_enabled                                      = var.vtpm_enabled
  zone_balance                                      = var.zone_balance
  zones                                             = var.zones

  dynamic "network_interface" {
    for_each = var.network_interfaces

    content {
      name = network_interface.name

      dynamic "ip_configuration" {
        for_each = network_interface.ip_configuration

        content {
          name      = ip_configuration.name
          primary   = ip_configuration.primary
          subnet_id = ip_configuration.subnet_id
        }
      }

      dns_servers                   = network_interface.dns_servers
      enable_accelerated_networking = network_interface.enable_accelerated_networking
      enable_ip_forwarding          = network_interface.enable_ip_forwarding
      network_security_group_id     = network_interface.network_security_group_id
      primary                       = network_interface.primary
    }
  }

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings == null ? {} : var.os_disk.diff_disk_settings

      content {
        option    = diff_disk_settings.option
        placement = diff_disk_settings.placement
      }
    }

    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled
  }

  dynamic "additional_capabilities" {
    for_each = var.additional_capabilities == null ? [] : var.additional_capabilities

    content {
      ultra_ssd_enabled = additional_capabilities.ultra_ssd_enabled
    }
  }

  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_keys == null ? [] : var.admin_ssh_keys

    content {
      public_key = admin_ssh_key.public_key
      username   = admin_ssh_key.username
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.automatic_os_upgrade_policy == null ? {} : var.automatic_os_upgrade_policy

    content {
      disable_automatic_rollback  = automatic_os_upgrade_policy.disable_automatic_rollback
      enable_automatic_os_upgrade = automatic_os_upgrade_policy.enable_automatic_os_upgrade
    }
  }

  dynamic "automatic_instance_repair" {
    for_each = var.automatic_instance_repair == null ? {} : var.automatic_instance_repair

    content {
      enabled      = automatic_instance_repair.enabled
      grace_period = automatic_instance_repair.grace_period
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics == null ? {} : var.boot_diagnostics

    content {
      storage_account_uri = boot_diagnostics.storage_account_uri
    }
  }

  dynamic "data_disk" {
    for_each = var.data_disk == null ? [] : var.data_disk

    content {
      name                           = data_disk.name
      caching                        = data_disk.caching
      create_option                  = data_disk.create_option
      disk_size_gb                   = data_disk.disk_size_gb
      lun                            = data_disk.lun
      storage_account_type           = data_disk.storage_account_type
      disk_encryption_set_id         = data_disk.disk_encryption_set_id
      ultra_ssd_disk_iops_read_write = data_disk.ultra_ssd_disk_iops_read_write
      ultra_ssd_disk_mbps_read_write = data_disk.ultra_ssd_disk_mbps_read_write
      write_accelerator_enabled      = data_disk.write_accelerator_enabled
    }
  }

  dynamic "extension" {
    for_each = var.extensions == null ? [] : var.extensions

    content {
      name                       = extension.name
      publisher                  = extension.publisher
      type                       = extension.type
      type_handler_version       = extension.type_handler_version
      auto_upgrade_minor_version = extension.auto_upgrade_minor_version
      automatic_upgrade_enabled  = extension.automatic_upgrade_enabled
      force_update_tag           = extension.force_update_tag
      protected_settings         = extension.protected_settings

      dynamic "protected_settings_from_key_vault" {
        for_each = extension.protected_settings_from_key_vault == null ? {} : extension.protected_settings_from_key_vault

        content {
          secret_url      = protected_settings_from_key_vault.secret_url
          source_vault_id = protected_settings_from_key_vault.source_vault_id
        }
      }

      provision_after_extensions = extension.provision_after_extensions
      settings                   = extension.settings
    }
  }

  dynamic "gallery_application" {
    for_each = var.gallery_applications == null ? [] : var.gallery_applications

    content {
      version_id             = gallery_application.version_id
      configuration_blob_uri = gallery_application.configuration_blob_uri
      order                  = gallery_application.order
      tag                    = gallery_application.tag
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? {} : var.identity

    content {
      type         = identity.type
      identity_ids = identity.identity_ids
    }
  }

  dynamic "plan" {
    for_each = var.plan == null ? {} : var.plan

    content {
      name      = plan.name
      publisher = plan.publisher
      product   = plan.product
    }
  }

  dynamic "rolling_upgrade_policy" {
    for_each = var.rolling_upgrade_policy == null ? {} : var.rolling_upgrade_policy

    content {
      cross_zone_upgrades_enabled             = rolling_upgrade_policy.cross_zone_upgrades_enabled
      max_batch_instance_percent              = rolling_upgrade_policy.max_batch_instance_percent
      max_unhealthy_instance_percent          = rolling_upgrade_policy.max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = rolling_upgrade_policy.max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = rolling_upgrade_policy.pause_time_between_batches
      prioritize_unhealthy_instances_enabled  = rolling_upgrade_policy.prioritize_unhealthy_instances_enabled
    }
  }

  dynamic "scale_in" {
    for_each = var.scale_in == null ? {} : var.scale_in

    content {
      rule                   = scale_in.rule
      force_deletion_enabled = scale_in.force_deletion_enabled
    }
  }

  dynamic "secret" {
    for_each = var.secrets == null ? [] : var.secrets

    content {
      dynamic "certificate" {
        for_each = secret.certificate

        content {
          url = certificate.url
        }
      }

      key_vault_id = secret.key_vault_id
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_reference == null ? {} : var.source_image_reference

    content {
      publisher = source_image_reference.publisher
      offer     = source_image_reference.offer
      sku       = source_image_reference.sku
      version   = source_image_reference.version
    }
  }

  dynamic "spot_restore" {
    for_each = var.spot_restore == null ? {} : var.spot_restore

    content {
      enabled = spot_restore.enabled
      timeout = spot_restore.timeout
    }
  }

  dynamic "termination_notification" {
    for_each = var.termination_notification == null ? {} : var.termination_notification

    content {
      enabled = termination_notification.enabled
      timeout = termination_notification.timeout
    }
  }

  lifecycle {
    ignore_changes = [
      instances
    ]
  }
}
