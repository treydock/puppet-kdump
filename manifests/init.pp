# @summary Manage kdump
#
# @example Use default actions of ensuring kdump is running
#   class { 'kdump': }
# @example Example of how to disable kdump
#   class { 'kdump':
#     service_ensure => 'stopped',
#     service_enable => false,
#   }
#
# @param enable
#   Set state of kdump.
#   `true` - Ensure service running and crashkernel kernel argument set
#   `false` - Ensure service stopped and crashkernel kernel argument absent
# @param crashkernel
#   Kernel crashkernel argument value
# @param crashkernel_bootmode
#   The bootmode for crashkernel kernel argument
# @param bootloader_config_path
#   Path to boot loader config
# @param package_name
#   Package name that provides kdump.
# @param service_name
#   Service name for kdump.
# @param service_ensure
#   The service ensure property for kdump.
# @param service_enable
#   The service enable property for kdump.
# @param service_hasstatus
#   The service hasstatus property for kdump.
# @param service_hasrestart
#   The service hasrestart property for kdump.
# @param service_autorestart
#   This parameter defines if the kdump service
#   Should be restarted when the configuration file changes.
# @param config_path
#   The configuration file path for kdump.
# @param config_overrides
#   Hash of config values to add to kdump.conf
# @param kernel_parameter_provider
#   The provider property for the kernel_parameter defined type.
class kdump (
  Boolean                        $enable                    = false,
  String                         $crashkernel               = 'auto',
  String                         $crashkernel_bootmode      = 'all',
  Optional[Stdlib::AbsolutePath] $bootloader_config_path    = undef,
  String                         $package_name              = $kdump::params::package_name,
  String                         $service_name              = $kdump::params::service_name,
  Optional[String]               $service_ensure            = undef,
  Optional[Boolean]              $service_enable            = undef,
  Boolean                        $service_hasstatus         = $kdump::params::service_hasstatus,
  Boolean                        $service_hasrestart        = $kdump::params::service_hasrestart,
  Stdlib::AbsolutePath           $config_path               = $kdump::params::config_path,
  Hash                           $config_overrides          = {},
  String                         $kernel_parameter_provider = $kdump::params::kernel_parameter_provider,
) inherits kdump::params {

  $config = merge($kdump::params::config_defaults, $config_overrides)

  if $enable {
    $service_ensure_real = pick($service_ensure, 'running')
    $service_enable_real = pick($service_enable, true)
    $crashkernel_ensure  = 'present'
  } else {
    $service_ensure_real = 'stopped'
    $service_enable_real = false
    $crashkernel_ensure  = 'absent'
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
    ensure     => $service_ensure_real,
    enable     => $service_enable_real,
    name       => $service_name,
    hasstatus  => $service_hasstatus,
    hasrestart => $service_hasrestart,
  }

}
