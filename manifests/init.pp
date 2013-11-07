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
  $crashkernel_ensure     = 'present',
  $crashkernel            = $kdump::params::crashkernel,
  $crashkernel_bootmode   = 'all',
  $bootloader_config_path = 'UNSET',
  $package_name           = $kdump::params::package_name,
  $service_name           = $kdump::params::service_name,
  $service_ensure         = 'stopped',
  $service_enable         = false,
  $service_hasstatus      = $kdump::params::service_hasstatus,
  $service_hasrestart     = $kdump::params::service_hasrestart,
  $service_autorestart    = true,
  $config_path            = $kdump::params::config_path
) inherits kdump::params {

  validate_re($crashkernel_ensure, ['^present$','^absent$'])
  validate_bool($service_autorestart)

  $bootloader_config_path_real = $bootloader_config_path ? {
    'UNSET' => undef,
    default => $bootloader_config_path,
  }

  # This gives the option to not manage the service 'ensure' state.
  $service_ensure_real  = $service_ensure ? {
    'undef'   => undef,
    default   => $service_ensure,
  }

  # This gives the option to not manage the service 'enable' state.
  $service_enable_real  = $service_enable ? {
    'undef'   => undef,
    default   => $service_enable,
  }

  $service_subscribe = $service_autorestart ? {
    true  => File['/etc/kdump.conf'],
    false => undef,
  }

  kernel_parameter { 'crashkernel':
    ensure    => $crashkernel_ensure,
    value     => $crashkernel,
    target    => $bootloader_config_path_real,
    bootmode  => $crashkernel_bootmode,
  }

  package { 'kexec-tools':
    ensure  => present,
    name    => $package_name,
    before  => File['/etc/kdump.conf'],
  }

  service { 'kdump':
    ensure      => $service_ensure_real,
    enable      => $service_enable_real,
    name        => $service_name,
    hasstatus   => $service_hasstatus,
    hasrestart  => $service_hasrestart,
    subscribe   => $service_subscribe,
  }

  file { '/etc/kdump.conf':
    ensure  => present,
    path    => $config_path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

}
