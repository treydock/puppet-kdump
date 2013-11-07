# == Class: kdump::params
#
# The kdump configuration settings.
#
# === Variables
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class kdump::params {

  case $::osfamily {
    'RedHat': {
      $package_name       = 'kexec-tools'
      $service_name       = 'kdump'
      $service_hasstatus  = true
      $service_hasrestart = true
      $config_path        = '/etc/kdump.conf'

      if $::memorysize_mb >= 4096 {
        $crashkernel  = 'auto'
      } else {
        $crashkernel  = $::operatingsystemrelease ? {
          /^5/    => '128M@16M',
          default => '128M',
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}