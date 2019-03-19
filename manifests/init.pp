# == Class: kdump
#
# Full description of class kdump here.
#
# === Parameters
#
# [*package_name*]
#   String.  Package name that provides kdump.
#   Default: OS dependent
#
# [*service_name*]
#   String.  Service name for kdump.
#   Default: OS dependent
#
# [*service_ensure*]
#   The service ensure property for kdump.
#   Default: 'running'
#
# [*service_enable*]
#   The service enable property for kdump.
#   Default: true
#
# [*service_hasstatus*]
#   The service hasstatus property for kdump.
#   Default: OS dependent
#
# [*service_hasrestart*]
#   The service hasrestart property for kdump.
#   Default: OS dependent
#
# [*service_autorestart*]
#   Boolean.  This parameter defines if the kdump service
#   Should be restarted when the configuration file changes.
#   Default: true
#
# [*config_path*]
#   The configuration file path for kdump.
#   Default: OS dependent
#
# [*kernel_parameter_provider*]
#   The provider property for the kernel_parameter defined type.
#   Default: OS dependent
#
# === Variables
#
# === Examples
#
#  Use default actions of ensuring kdump is running
#
#  class { 'kdump': }
#
#  Example of how to disable kdump
#
#  class { 'kdump':
#    service_ensure => 'stopped',
#    service_enable => false,
#  }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class kdump (
  Boolean                        $enable                    = false,
  String                         $crashkernel               = 'auto',
  String                         $crashkernel_bootmode      = 'all',
  Optional[Stdlib::AbsolutePath] $bootloader_config_path    = undef,
  String                         $package_name              = $kdump::params::package_name,
  String                         $service_name              = $kdump::params::service_name,
  Boolean                        $service_hasstatus         = $kdump::params::service_hasstatus,
  Boolean                        $service_hasrestart        = $kdump::params::service_hasrestart,
  Stdlib::AbsolutePath           $config_path               = $kdump::params::config_path,
  Hash                           $config_overrides          = {},
  String                         $kernel_parameter_provider = $kdump::params::kernel_parameter_provider,
) inherits kdump::params {

  $config = merge($kdump::params::config_defaults, $config_overrides)

  if $enable {
    $service_ensure     = 'running'
    $service_enable     = true
    $crashkernel_ensure = 'present'
  } else {
    $service_ensure     = 'stopped'
    $service_enable     = false
    $crashkernel_ensure = 'absent'
  }

  if $enable {
    kernel_parameter { 'crashkernel':
      ensure   => 'present',
      value    => $crashkernel,
      target   => $bootloader_config_path,
      bootmode => $crashkernel_bootmode,
      provider => $kernel_parameter_provider,
    }

    package { 'kexec-tools':
      ensure => present,
      name   => $package_name,
      before => File['/etc/kdump.conf'],
    }

    file { '/etc/kdump.conf':
      ensure  => present,
      path    => $config_path,
      content => template('kdump/kdump.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Service['kdump'],
    }

    if $::kernel_arguments !~ /crashkernel/ {
      notify { 'kdump':
        message => 'A reboot is required to fully enable the crashkernel'
      }
    }
  } else {
    kernel_parameter { 'crashkernel':
      ensure   => 'absent',
      provider => $kernel_parameter_provider,
    }

    if $::kernel_arguments =~ /crashkernel/ {
      notify { 'kdump':
        message => 'A reboot is required to fully disable the crashkernel'
      }
    }
  }

  service { 'kdump':
    ensure     => $service_ensure,
    enable     => $service_enable,
    name       => $service_name,
    hasstatus  => $service_hasstatus,
    hasrestart => $service_hasrestart,
  }

}
