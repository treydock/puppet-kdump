# @summary Manage kdump
#
# @example Use default actions of ensuring kdump is stopped
#   class { 'kdump': }
#
# @example Example of how to enable kdump
#   class { 'kdump':
#     enable => true,
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
# @param config_path
#   The configuration file path for kdump.
# @param config_overrides
#   Hash of config values to add to kdump.conf
# @param kernel_parameter_provider
#   The provider property for the kernel_parameter defined type.
# @param manage_kernel_parameter
#   Controls if kernel_parameter resource is managed
# @param grub_kdump_cfg
#   Path to grub2 kdump config. Only used on Ubuntu.
class kdump (
  Boolean                        $enable                    = false,
  String                         $crashkernel               = 'auto',
  String                         $crashkernel_bootmode      = 'all',
  Optional[Stdlib::AbsolutePath] $bootloader_config_path    = undef,
  String                         $package_name              = 'kexec-tools',
  String                         $service_name              = 'kdump',
  Optional[String]               $service_ensure            = undef,
  Optional[Boolean]              $service_enable            = undef,
  Boolean                        $service_hasstatus         = true,
  Boolean                        $service_hasrestart        = true,
  Stdlib::AbsolutePath           $config_path               = '/etc/kdump.conf',
  Hash                           $config_overrides          = {},
  String                         $kernel_parameter_provider = 'grub2',
  Boolean                        $manage_kernel_parameter   = true,
  Optional[String]               $grub_kdump_cfg            = undef,
) {

  $osfamily = dig($facts, 'os', 'family')
  if ! ($osfamily in ['RedHat', 'Debian']) {
    fail("Unsupported osfamily: ${osfamily}, module ${module_name} only support RedHat and Debian")
  }

  $config_defaults = {
    'path'              => '/var/crash',
    'core_collector'    => 'makedumpfile -c --message-level 1 -d 31',
    'raw'               => 'UNSET',
    'nfs'               => 'UNSET',
    'nfs4'              => 'UNSET',
    'ssh'               => 'UNSET',
    'ext4'              => 'UNSET',
    'ext3'              => 'UNSET',
    'ext2'              => 'UNSET',
    'minix'             => 'UNSET',
    'btrfs'             => 'UNSET',
    'xfs'               => 'UNSET',
    'link_delay'        => 'UNSET',
    'kdump_post'        => 'UNSET',
    'kdump_pre'         => 'UNSET',
    'extra_bins'        => 'UNSET',
    'extra_modules'     => 'UNSET',
    'options'           => 'UNSET',
    'blacklist'         => 'UNSET',
    'sshkey'            => 'UNSET',
    'default'           => 'UNSET',
    'debug_mem_level'   => 'UNSET',
    'force_rebuild'     => 'UNSET',
  }

  $config = merge($config_defaults, $config_overrides)

  if $enable {
    if $facts['crashkernel'] {
      $service_ensure_default = 'running'
    } else {
      $service_ensure_default = 'stopped'
    }
    $service_ensure_real = pick($service_ensure, $service_ensure_default)
    $service_enable_real = pick($service_enable, true)
    $crashkernel_ensure  = 'present'
  } else {
    $service_ensure_real = 'stopped'
    $service_enable_real = false
    $crashkernel_ensure  = 'absent'
  }

  if $enable {
    if $manage_kernel_parameter {
      kernel_parameter { 'crashkernel':
        ensure   => 'present',
        value    => $crashkernel,
        target   => $bootloader_config_path,
        bootmode => $crashkernel_bootmode,
        provider => $kernel_parameter_provider,
      }
    }

    if $grub_kdump_cfg {
      file { $grub_kdump_cfg:
        ensure  => 'file',
        content => "GRUB_CMDLINE_LINUX_DEFAULT=\"\$GRUB_CMDLINE_LINUX_DEFAULT crashkernel=${crashkernel}\"",
      }
      if $manage_kernel_parameter {
        File[$grub_kdump_cfg] -> Kernel_parameter['crashkernel']
      }
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

    if ! $facts['crashkernel'] {
      notify { 'kdump':
        message => 'A reboot is required to fully enable the crashkernel'
      }
    }
  } else {
    if $manage_kernel_parameter {
      kernel_parameter { 'crashkernel':
        ensure   => 'absent',
        provider => $kernel_parameter_provider,
      }
    }

    if $grub_kdump_cfg {
      file { $grub_kdump_cfg:
        ensure  => 'file',
        content => "GRUB_CMDLINE_LINUX_DEFAULT=\"\$GRUB_CMDLINE_LINUX_DEFAULT\"",
      }
      if $manage_kernel_parameter {
        File[$grub_kdump_cfg] -> Kernel_parameter['crashkernel']
      }
    }

    if $facts['crashkernel'] {
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
